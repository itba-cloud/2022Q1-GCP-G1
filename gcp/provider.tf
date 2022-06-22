provider "google" {
  project = var.project_name
  region  = var.region
  credentials = file("the-stocker-2022-0046b4714fe7.json")
}

provider "google-beta" {
  project = var.project_name
  region  = var.region
  credentials = file("the-stocker-2022-0046b4714fe7.json")
}