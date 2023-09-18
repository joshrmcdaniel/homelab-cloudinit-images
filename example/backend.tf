terraform {
  required_version = ">= 0.13"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.4"
    }
  }
}
