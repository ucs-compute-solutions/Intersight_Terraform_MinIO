//Define all the basic variables here

variable "api_private_key" {
  default = "/root/terraform-intersight-sds/intersight.pem"
}

variable "api_key_id" {
  default = "5e5fb2b17564612d3028b5b4/5e5fbd137564612d3028bcc4/5fa1a9107564612d3007f934"
}

variable "api_endpoint" {
  default = "https://sjc02dmz-intersight.sjc02dmz.net"
}

variable "management_vlan" {
  default = 300
}

variable "client_vlan" {
  default = 301
}

variable "storage_vlan" {
  default = 302
}

variable "remote-server" {
  default = "sjc02dmz-i14-terraform.sjc02dmz.net"
}

variable "remote-share" {
  default = "/images"
}

variable "remote-os-image-minio" {
  type = list(string)
  default = ["rhel8.2-minio5.iso", "rhel8.2-minio6.iso"]
}

variable "remote-os-image-link" {
  type = list(string)
  default = ["http://sjc02dmz-i14-terraform.sjc02dmz.net/images/rhel8.2-minio5.iso", "http://sjc02dmz-i14-terraform.sjc02dmz.net/images/rhel8.2-minio5.iso"]
}

variable "remote-protocol" {
  default = "softwarerepository.HttpServer"
}

variable "server_names" {
  default = ["sjc02dmz-i14-c240m5l5", "sjc02dmz-i14-c240m5l6"]
}

variable "organization_name" {
  default = "Minio"
}

variable "server_profile_action" {
  default = "No-op"
}

variable "catalog_name" {
  default = "appliance-user-catalog"
}
