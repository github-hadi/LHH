output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = "appadmin"
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = local.vm_password
  sensitive   = true
}

output "app_private_ip" {
  value = azurerm_virtual_machine.app-nic.private_ip_address
}

output "app_public_ip" {
   value = azurerm_virtual_machine.app-nic.public_ip_address_id
}