packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/vmware"
    }
  }
}