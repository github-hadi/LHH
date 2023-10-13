output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = "appadmin"
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = local.vm_password
  sensitive   = true
}

#output "app_ip" {
#  value = azurerm_virtual_machine.app-nic.private_ip_address
   value = azurerm_virtual_machine.app-nic.app-vm-public_ip
#}

