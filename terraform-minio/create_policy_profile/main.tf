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
  catalog_name 		= var.catalog_name
}

resource "intersight_server_profile" "minio" {
  count  = length(var.server_names)
  name = "SP-${var.server_names[count.index]}"
  organization {
    object_type = "organization.Organization"
    moid        = module.intersight-moids.organization_moid
  }
  assigned_server {
    moid        = module.intersight-moids.server_moids[count.index]
    object_type = "compute.RackUnit"
  }
  action = var.server_profile_action
}

resource "intersight_networkconfig_policy" "minio-network-policy" {
  name        = "minio-network-policy"
  description = "DNS Configuration Policy for CIMC"
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
  preferred_ipv4dns_server = "192.168.10.51"
  alternate_ipv4dns_server = ""
  dynamic "profiles" {
    for_each = intersight_server_profile.minio
    content {
      moid = profiles.value["moid"]
      object_type = "server.Profile"
    }
  }
}

resource "intersight_adapter_config_policy" "minio-adapter-config-policy" {
  name        = "minio-adapter-config-policy"
  description = "Adapter Configuration Policy for Minio"
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
  settings {
    slot_id = "MLOM"
	dce_interface_settings {
	  fec_mode = "cl74"
	  interface_id = "0"
	}
	dce_interface_settings {
	  fec_mode = "cl74"
	  interface_id = "1"
	}
	dce_interface_settings {
	  fec_mode = "cl74"
	  interface_id = "2"
	}
	dce_interface_settings {
	  fec_mode = "cl74"
	  interface_id = "3"
	}
    eth_settings {
      lldp_enabled = true
    }
    fc_settings {
      fip_enabled = false
    }
	port_channel_settings {
	  enabled = "true"
	}
  }
  dynamic "profiles" {
    for_each = intersight_server_profile.minio
    content {
      moid = profiles.value["moid"]
      object_type = "server.Profile"
    }
  }
}

resource "intersight_vnic_eth_adapter_policy" "minio-ethernet-adapter-policy" {
  name = "minio-ethernet-adapter-policy"
  description = "Ethernet Adapter Policy for Minio"
  rss_settings = true
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
  vxlan_settings {
    object_type = "vnic.VxlanSettings"
    enabled = false
  }
  nvgre_settings {
    enabled = false
    object_type = "vnic.NvgreSettings"
  }
  arfs_settings {
    object_type = "vnic.ArfsSettings"
	enabled = true
  }
  roce_settings {
    object_type = "vnic.RoceSettings"
	enabled = false
  }
  interrupt_settings {
    coalescing_time = 125
    coalescing_type = "MIN"
    nr_count           = 11
    mode            = "MSIx"
    object_type = "vnic.EthInterruptSettings"
  }
  completion_queue_settings {
    object_type = "vnic.CompletionQueueSettings"
    nr_count     = 9
    ring_size = 1
  }
  rx_queue_settings {
    object_type = "vnic.EthRxQueueSettings"
    nr_count     = 8
    ring_size = 4096
  }
  tx_queue_settings {
    object_type = "vnic.EthTxQueueSettings"
    nr_count     = 1
    ring_size = 4096
  }
  tcp_offload_settings {
    object_type = "vnic.TcpOffloadSettings"
    large_receive = true
    large_send    = true
    rx_checksum   = true
    tx_checksum   = true
  }
}

resource "intersight_vnic_eth_network_policy" "minio-mgt-network" {
  name = "minio-mgt-network"
  description = "Mgt Network for Minio"
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
  vlan_settings {
    object_type = "vnic.VlanSettings"
    default_vlan = var.management_vlan
    mode         = "TRUNK"
  }
}

resource "intersight_vnic_eth_network_policy" "minio-client-network" {
  name = "minio-client-network"
  description = "Client Network for Minio"
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
  vlan_settings {
    object_type = "vnic.VlanSettings"
    default_vlan = var.client_vlan
    mode         = "TRUNK"
  }
}

resource "intersight_vnic_eth_network_policy" "minio-storage-network" {
  name = "minio-storage-network"
  description = "Storage Network for Minio"
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
  vlan_settings {
    object_type = "vnic.VlanSettings"
    default_vlan = var.storage_vlan
    mode         = "TRUNK"
  }
}

resource "intersight_vnic_eth_qos_policy" "minio-ethernet-qos-9000-policy" {
  name           = "minio-ethernet-qos-9000-policy"
  description = "Ethernet quality of service for Minio"
  mtu            = 9000
  rate_limit     = 0
  cos            = 0
  trust_host_cos = false
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
}

resource "intersight_vnic_eth_qos_policy" "minio-ethernet-qos-1500-policy" {
  name           = "minio-ethernet-qos-1500-policy"
  description = "Ethernet quality of service for Minio"
  mtu            = 1500
  rate_limit     = 0
  cos            = 0
  trust_host_cos = false
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
}

resource "intersight_vnic_lan_connectivity_policy" "minio-lan-connectivity-policy" {
  name = "minio-lan-connectivity-policy"
  description = "LAN Connectivity Policy for Minio"
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
  dynamic "profiles" {
    for_each = intersight_server_profile.minio
    content {
      moid = profiles.value["moid"]
      object_type = "server.Profile"
    }
  }
}

resource "intersight_vnic_eth_if" "eth0" {
  name  = "eth0"
  order = 0
  placement {
    object_type = "vnic.PlacementSettings"
    id     = "MLOM"
    pci_link = 0
    uplink = 0
  }
  cdn {
    nr_source = "vnic"
  }
  vmq_settings {
    enabled = false
	num_interrupts = 1
    num_vmqs = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.minio-lan-connectivity-policy.id
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.minio-mgt-network.id
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.minio-ethernet-adapter-policy.id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.minio-ethernet-qos-1500-policy.id
  }
}

resource "intersight_vnic_eth_if" "eth1" {
  name  = "eth1"
  order = 1
  placement {
    object_type = "vnic.PlacementSettings"
    id     = "MLOM"
    pci_link = 0
    uplink = 0
  }
  cdn {
    nr_source = "vnic"
  }
  vmq_settings {
    enabled = false
	num_interrupts = 1
    num_vmqs = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.minio-lan-connectivity-policy.id
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.minio-client-network.id
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.minio-ethernet-adapter-policy.id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.minio-ethernet-qos-9000-policy.id
  }
}

resource "intersight_vnic_eth_if" "eth2" {
  name  = "eth2"
  order = 2
  placement {
    object_type = "vnic.PlacementSettings"
    id     = "MLOM"
    pci_link = 0
    uplink = 1
  }
  cdn {
    nr_source = "vnic"
  }
  vmq_settings {
    enabled = false
	num_interrupts = 1
    num_vmqs = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.minio-lan-connectivity-policy.id
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.minio-client-network.id
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.minio-ethernet-adapter-policy.id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.minio-ethernet-qos-9000-policy.id
  }
}

resource "intersight_vnic_eth_if" "eth3" {
  name  = "eth3"
  order = 3
  placement {
    object_type = "vnic.PlacementSettings"
    id     = "MLOM"
    pci_link = 0
    uplink = 0
  }
  cdn {
    nr_source = "vnic"
  }
  vmq_settings {
    enabled = false
	num_interrupts = 1
    num_vmqs = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.minio-lan-connectivity-policy.id
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.minio-storage-network.id
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.minio-ethernet-adapter-policy.id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.minio-ethernet-qos-9000-policy.id
  }
}

resource "intersight_vnic_eth_if" "eth4" {
  name  = "eth4"
  order = 4
  placement {
    object_type = "vnic.PlacementSettings"
    id     = "MLOM"
    pci_link = 0
    uplink = 1
  }
  cdn {
    nr_source = "vnic"
  }
  vmq_settings {
    enabled = false
	num_interrupts = 1
    num_vmqs = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.minio-lan-connectivity-policy.id
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.minio-storage-network.id
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.minio-ethernet-adapter-policy.id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.minio-ethernet-qos-9000-policy.id
  }
}

resource "intersight_ntp_policy" "minio-ntp-policy" {
  name    = "minio-ntp-policy"
  description = "NTP Policy for Minio"
  enabled = true
  ntp_servers = [
    "173.38.201.115"
  ]
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
  dynamic "profiles" {
    for_each = intersight_server_profile.minio
    content {
      moid = profiles.value["moid"]
      object_type = "server.Profile"
    }
  }
}

resource "intersight_storage_disk_group_policy" "minio-disk-group-boot-policy-c240" {
  name        = "minio-disk-group-boot-policy-c240"
  description = "Disk Group Boot Policy for Minio"
  raid_level  = "Raid1"
  use_jbods   = true
  span_groups {
    disks {
      slot_number = 13
    }
    disks {
      slot_number = 14
    }
  }
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
}

resource "intersight_storage_storage_policy" "minio-storage-policy" {
  name                         = "minio-storage-policy"
  description                  = "Storage Policy for Minio"
  retain_policy_virtual_drives = false
  unused_disks_state           = "Jbod"
  virtual_drives {
    object_type = "storage.VirtualDriveConfig"
    boot_drive = true
    drive_cache = "Default"
    expand_to_available = true
    io_policy = "Default"
    name = "minio-os-boot"
    access_policy = "ReadWrite"
    disk_group_policy = intersight_storage_disk_group_policy.minio-disk-group-boot-policy-c240.id
    read_policy = "ReadAhead"
    write_policy = "WriteBackGoodBbu"
  }
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
  dynamic "profiles" {
    for_each = intersight_server_profile.minio
    content {
      moid = profiles.value["moid"]
      object_type = "server.Profile"
    }
  }
}

resource "intersight_boot_precision_policy" "minio-boot-policy" {
  name                     = "minio-boot-policy"
  description              = "Boot Policy for Minio"
  configured_boot_mode     = "Legacy"
  enforce_uefi_secure_boot = false
  organization {
    object_type = "organization.Organization"
    moid = module.intersight-moids.organization_moid
  }
  boot_devices {
    enabled     = true
    name        = "disk"
    object_type = "boot.LocalDisk"
    additional_properties = jsonencode({
      Slot = "MRAID"
    })
  }
  boot_devices {
    enabled     = true
    name        = "vmedia"
    object_type = "boot.VirtualMedia"
    additional_properties = jsonencode({
      Subtype = "cimc-mapped-dvd"
    })
  }
  dynamic "profiles" {
    for_each = intersight_server_profile.minio
    content {
      moid = profiles.value["moid"]
      object_type = "server.Profile"
    }
  }
}
