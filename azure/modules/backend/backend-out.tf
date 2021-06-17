output "api_url" {
  value = "${azurerm_api_management.api_management.gateway_url}/counter"
}