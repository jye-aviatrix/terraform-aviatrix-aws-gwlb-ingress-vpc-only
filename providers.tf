terraform {
  required_providers {

    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      version = "2.21.1-6.6.ga"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}