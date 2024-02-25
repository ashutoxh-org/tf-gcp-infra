terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~>4"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.deployment_region
}

provider "google-beta" {
  project = var.project_id
  region  = var.deployment_region
}
