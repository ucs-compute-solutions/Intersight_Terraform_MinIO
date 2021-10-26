# Intersight Provider Information 
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = "1.0.15"
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
  catalog_name = var.catalog_name
}

resource "intersight_softwarerepository_operating_system_file" "rhel-custom-iso-with-kickstart-minio" {
  count = length(var.server_names)
  nr_version = "Red Hat Enterprise Linux 8.2"
  description = "RHEL 8.2 installer ISO with embedded kickstart MinIO"
  name = "ISO-${var.server_names[count.index]}"
  nr_source {
    additional_properties = jsonencode({
	  LocationLink = var.remote-os-image-link[count.index]
	  })
	object_type = var.remote-protocol
  }
  vendor = "Red Hat"
  catalog {
	moid = module.intersight-moids.catalog_moid
  }
}

resource "intersight_os_install" "minio" {
  count = length(var.server_names)
  name = "minio-os-${var.server_names[count.index]}"
  server {
    object_type = "compute.RackUnit"
    moid = module.intersight-moids.server_moids[count.index]
  }
  image {
    object_type = "softwarerepository.OperatingSystemFile"
    moid = intersight_softwarerepository_operating_system_file.rhel-custom-iso-with-kickstart-minio[count.index].moid
  }
  answers {
    nr_source = "Embedded"
  }
  description = "OS install"
  install_method = "vMedia"
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
}
