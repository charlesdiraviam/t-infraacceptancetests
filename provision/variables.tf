variable "resource_group_name" {
  type    = string
  default = "terraform-vm"
}

variable "location" {
  type    = string
  default = "australiaeast"
}

variable "vnet_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.0.0.0/24"]
}

variable "subnet_names" {
  type    = list(string)
  default = ["subnet1"]
}


variable "ssh_public_key_path" {
  type    = string
  default = null
}

variable "restrict_to_ip_range" {
  type =  string
  default = "null"
}

variable "remote_ssh_port" {
  type =  string
  default = "22"
}
variable "tags" {
  type = map(string)
}

variable "nsg_name" {
  type = string
}

variable "vm_name" {
  type = string
}
 
resource "random_id" "id" {
  byte_length = 4
}

locals {
  storage_account_name = "terraformstate${lower(random_id.id.hex)}"
  vm_public_dns        = "tfvm-${random_id.id.hex}"
}