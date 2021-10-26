# Intersight Provider Information 
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = "1.0.15"
    }
  }
}

data "intersight_compute_physical_summary" "server_moid" {
  name  = var.server_names[count.index]
  count = length(var.server_names)
}

output "server_moids" {
  value = data.intersight_compute_physical_summary.server_moid.*.results.0.moid
}

data "intersight_organization_organization" "organization_moid" {
  name = var.organization_name
}

output "organization_moid" {
  value = data.intersight_organization_organization.organization_moid.results[0].moid
}

data "intersight_softwarerepository_catalog" "catalog_moid" {
  name = var.catalog_name
}

output "catalog_moid" {
  value = data.intersight_softwarerepository_catalog.catalog_moid.results[0].moid
}
