output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = "appadmin"
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = local.vm_password
  sensitive   = true
}

output "app_ip" {
  value = azurerm_linux_virtual_machine.azurerm_linux_virtual_machine.private_ip_address
}