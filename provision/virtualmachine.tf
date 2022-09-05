# Password for Terraform VM
resource "random_password" "terraform_vm" {
  length  = 16
  special = true
}

# Resource group for Terraform VM
resource "azurerm_resource_group" "vnet_main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags

}

# Network for Terraform VM
module "vnet-main"  {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = azurerm_resource_group.vnet_main.name
  vnet_name           = var.resource_group_name
  address_space       = [var.vnet_cidr_range]
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  nsg_ids             = { subnet1 = azurerm_network_security_group.terraform_nsg.id }
  tags                = var.tags

  depends_on = [azurerm_resource_group.vnet_main]
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "terraform_nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.vnet_main.location
  resource_group_name = azurerm_resource_group.vnet_main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.remote_ssh_port
    source_address_prefix      = var.restrict_to_ip_range
    destination_address_prefix = format("%s/32",join(",", module.terraform-vm.network_interface_private_ip ))
  }
}

# Storage account for Terraform VM
resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.vnet_main.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags


}

resource "azurerm_storage_container" "ct" {
  name                 = "terraform-state"
  storage_account_name = azurerm_storage_account.sa.name
}

# Compute deployment for Terraform VM using Ubuntu
module "terraform-vm" {
  source                        = "Azure/compute/azurerm"
  version                       = "~> 3.0"
  resource_group_name           = azurerm_resource_group.vnet_main.name
  vm_hostname                   = var.vm_name
  vm_os_simple                  = "UbuntuServer"
  public_ip_dns                 = [local.vm_public_dns]
  vnet_subnet_id                = module.vnet-main.vnet_subnets[0]
  remote_port                   = var.remote_ssh_port
  source_address_prefixes       = [var.restrict_to_ip_range]
  admin_password                = random_password.terraform_vm.result
  enable_ssh_key                = true
  ssh_key                       = var.ssh_public_key_path
  delete_os_disk_on_termination = true
  tags                          = var.tags


  custom_data = base64encode(templatefile("${path.module}/assets/script.tmpl", {
    input_value = var.tags
    output_file = "/var/tmp/tags"
  }))


  depends_on = [azurerm_resource_group.vnet_main]
}

