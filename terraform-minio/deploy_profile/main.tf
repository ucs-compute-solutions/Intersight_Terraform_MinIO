# Intersight Provider Information 
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = "1.0.12"
    }
  }
}

provider "intersight" {
  apikey        = var.api_key_id
  secretkey = var.api_private_key
  endpoint      = var.api_endpoint
}

module "intersight-moids" {
  source            = "../../terraform-intersight-moids"
  server_names      = var.server_names
  organization_name = var.organization_name
  catalog_name 		= var.catalog_name
}

resource "intersight_server_profile" "minio" {
  count = length(var.server_names)
  name = "SP-${var.server_names[count.index]}"
  organization {
    object_type = "organization.Organization"
    moid 		= module.intersight-moids.organization_moid
  }
  assigned_server {
    moid        = module.intersight-moids.server_moids[count.index]
    object_type = "compute.RackUnit"
  }
  action = "Deploy"
}
