output "public_ip_address" {
  value = { for k, vm in azurerm_windows_virtual_machine.my_terraform_vm : k => vm.public_ip_address }
}

output "admin_username" {
  value = { for k, vm in azurerm_windows_virtual_machine.my_terraform_vm : k => vm.admin_username }
}

output "admin_password" {
  value     = { for k, vm in azurerm_windows_virtual_machine.my_terraform_vm : k => vm.admin_password }
  sensitive = true
}
