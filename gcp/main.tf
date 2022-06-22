module "vpc" {
  source = "./modules/vpc"

  # VARIABLES
  vpc_name = "the-stocker-vpc"
  vpc_acccess_connector_name = "access-connector"
  vpc_access_connector_ip_cidr_range = "10.8.0.0/28"
}

module "subnets" {
  source = "./modules/subnets"

  # VARIABLES
  subnet_for_cloud_sql = local.subnets.for_cloud_sql
  vpc_name = module.vpc.vpc_name
  region = var.region

  # Depende de la VPC ya que una subnet vive dentro de la VPC
  depends_on = [
    module.vpc
  ]
}

module "gcs" {
  source = "./modules/gcs"

  # VARIABLES
  bucket_name = "www.the-stocker.com"
  storage_class = "STANDARD"
  resources = "./resources"
  certificate = local.ssl.certificate.filename
  key = local.ssl.key.filename
  region = var.region
  static_ip_name = "load-balancer-for-bucket-static-ip"
  objects = local.gcs.objects
}

module "cloud_run" {
  source = "./modules/cloud_run"

  # VARIABLES
  services = local.cloud_run.services
  region = var.region
  vpc_access_connector_name = module.vpc.vpc_access_connector_name

  # Depende de la VPC por el Serverless VPC Access
  depends_on = [
    module.vpc
  ]
}

module "gateway" {
  source = "./modules/gateway"

  # VARIABLES
  api_file_path = "./resources/gateway/api.yaml"
  static_ip_name = "load-balancer-for-gateway-static-ip"
  api_id = "api-gw"
  api_config_id = "api-gw-config"
  api_gw_id = "api-gw-gw"
  resources = "./resources"
  certificate = local.ssl.certificate.filename
  key = local.ssl.key.filename
  user_service_address = module.cloud_run.user_service_address
  post_service_address = module.cloud_run.post_service_address
  ama_service_address = module.cloud_run.ama_service_address
  feed_service_address = module.cloud_run.feed_service_address

  # Depende de Cloud Run ya que la API Gateway tiene las URLs de los servicios de Cloud Run
  depends_on = [
    module.cloud_run
  ]
}

module "dns"{
  source = "./modules/dns"

  # VARIABLES
  name = "the-stocker-dns-zone"
  dns_name = "the-stocker.com."
  dns_TTL = 300
  LB_bucket_static_ip = module.gcs.LB_static_ip

  # Depende de GCS ya que el DNS crea un registro que apunta al LB del bucket
  depends_on = [
    module.gcs
  ]
}

module "cloud_sql" {
  source = "./modules/cloud_sql"

  #VARIABLES
  database_name = "the-stocker-database"
  database_instance_name = "the-stocker-database-instance"
  vpc_self_link = module.vpc.vpc_self_link

  # Depende de la VPC y subnets para crear el Private Access
  depends_on = [
    module.vpc,
    module.subnets
  ]
}