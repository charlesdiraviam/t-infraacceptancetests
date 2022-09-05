#######################
# Terraform variables #
#######################

resource_group_name = "terraform-vm"
location = "australiaeast"
nsg_name = "TerraformNetworkSecurityGroup"
vm_name  = "secopschefvm"
vnet_cidr_range = "10.0.0.0/16"
subnet_prefixes = ["10.0.0.0/24"]
subnet_names = ["subnet1"]
tags = {
        environment = "terraform"
        costcenter  = "secopschef"
        purpose     = "t-infraacceptancetests"
    }
