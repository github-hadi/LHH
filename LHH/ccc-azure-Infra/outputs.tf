output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = "appadmin"
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = var.vm_password
  sensitive   = true
}

#output "app_ip" {
#  value = azurerm_virtual_machine.app-vm.private_ip_address
#}

output "subnet_ids" {
  description = "The identifiers of the created or sourced Subnets."
  value       = { for k, v in local.subnets : k => v.id }
}