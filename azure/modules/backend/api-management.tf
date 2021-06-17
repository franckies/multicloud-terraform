resource "azurerm_api_management" "api_management" {
  name                = "${var.prefix_name}-api-management04"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.region
  publisher_name      = "franckies"
  publisher_email     = "franckies@hello.io"
  sku_name            = "Developer_1" 
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_api_management_api" "counter" {
  name                  = "${var.prefix_name}-api-management-api-counter"
  api_management_name   = azurerm_api_management.api_management.name
  resource_group_name   = var.resource_group.name
  revision              = "1"
  display_name          = "Counter"
  path                  = ""
  protocols             = ["https"]
  service_url           = "https://${azurerm_function_app.function_app.default_hostname}/api"
  subscription_required = false
}

resource "azurerm_api_management_api_operation" "counter_get" {
  operation_id        = "counter-get"
  api_name            = azurerm_api_management_api.counter.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group.name
  display_name        = "Counter app GET endpoint"
  method              = "GET"
  url_template        = "/counter"
}

resource "azurerm_api_management_api_operation" "counter_post" {
  operation_id        = "counter-post"
  api_name            = azurerm_api_management_api.counter.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group.name
  display_name        = "Counter app POST endpoint"
  method              = "POST"
  url_template        = "/counter"
}

resource "azurerm_api_management_api_policy" "api_management_api_policy_api_public" {
  api_name            = azurerm_api_management_api.counter.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group.name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <authentication-managed-identity resource="${azuread_application.ad_application_function_app.application_id}" ignore-error="false" />
    <cors allow-credentials="false">
        <allowed-origins>
            <origin>*</origin>
        </allowed-origins>
        <allowed-methods>
            <method>GET</method>
            <method>POST</method>
        </allowed-methods>
        <allowed-headers>
            <header>content-type</header>
            <header>accept</header>
        </allowed-headers>
    </cors>
  </inbound>
  <outbound>
    <base />
    <set-header name="Access-Control-Allow-Origin" exists-action="override">
      <value>@(context.Request.Headers.GetValueOrDefault("Origin",""))</value>
    </set-header>
    <set-header name="Access-Control-Allow-Credentials" exists-action="override">
      <value>true</value>
    </set-header>
  </outbound>
</policies>
XML
}