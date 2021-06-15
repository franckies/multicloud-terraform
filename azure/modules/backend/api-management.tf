# resource "azurerm_api_management" "backend" {
#   name                = "${var.prefix_name}-apima"
#   resource_group_name = var.resource_group.name
#   location            = var.resource_group.region
#   publisher_name      = "PublisherName"
#   publisher_email     = "franckiesuper@gmail.com"

#   sku_name = "Consumption_0"
# }

# # Our general API definition, here we could include a nice swagger file or something
# resource "azurerm_api_management_api" "backend" {
#   name                = "backend-api"
#   resource_group_name = var.resource_group.name
#   api_management_name = azurerm_api_management.backend.name
#   revision            = "2"
#   display_name        = "Counter App API"
#   path                = "backend"
#   protocols           = ["https"]

#   import {
#     content_format = "openapi"
#     content_value  = file("${path.module}/api-spec.yml")
#   }
# }

# # A seperate backend definition, we need this to set our authorisation code for our azure function
# resource "azurerm_api_management_backend" "backend" {
#   name                = "backend-backend"
#   resource_group_name = var.resource_group.name
#   api_management_name = azurerm_api_management.backend.name
#   protocol            = "http"
#   url                 = "https://${azurerm_function_app.function_app.default_hostname}/api/"

#   # This depends on the existence of the named value, however terraform doesn't know this
#   # so we have to define it explicitly
#   #depends_on = [azurerm_api_management_named_value.backend]

#   credentials {
#     header = {
#       x-functions-key = "{{func-functionkey}}"
#     }
#   }
# }

# # To store our function code securely (so it isn't easily visible everywhere)
# # we store the value as a secret 'named value'
# # resource "azurerm_api_management_named_value" "backend" {
# #   name                = "func-functionkey"
# #   resource_group_name = var.resource_group.name
# #   api_management_name = azurerm_api_management.backend.name
# #   display_name        = "func-functionkey"
# #   value               = data.azurerm_function_app_host_keys.function-backend.master_key
# #   secret              = true
# # }

# # We use a policy on our API to set the backend, which has the configuration for the authentication code
# resource "azurerm_api_management_api_policy" "backend" {
#   api_name            = azurerm_api_management_api.backend.name
#   api_management_name = azurerm_api_management_api.backend.api_management_name
#   resource_group_name = var.resource_group.name

#   # Put any policy block here, has to beh XML :(
#   # More options: https://docs.microsoft.com/en-us/azure/api-management/api-management-policies
#   xml_content = <<XML
#     <policies>
#         <inbound>
#             <base />
#             <set-backend-service backend-id="${azurerm_api_management_backend.backend.name}" />
#         </inbound>
#     </policies>
#   XML
# }