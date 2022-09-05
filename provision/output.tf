output "public_ip_address" {
  value = module.terraform-vm.public_ip_address
}

output "password" {
  value = nonsensitive(random_password.terraform_vm.result)
}