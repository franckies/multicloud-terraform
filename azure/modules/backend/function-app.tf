################################################################################
# Function app
################################################################################
# Reference the backend application function
data "archive_file" "file_function_app" {
  # Ensure local file is created before zipping
  type        = "zip"
  source_dir  = "${path.module}/backend-app"
  output_path = "backend-app.zip"
}

# Create storage account holding the function code
resource "azurerm_storage_account" "storage_account" {
  name                     = "${replace(var.prefix_name, "-", "")}strg"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "${var.prefix_name}-storage-container-functions"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

# Storage blob within the container holding the zip archive
resource "azurerm_storage_blob" "storage_blob" {
  name                   = "${filesha256(data.archive_file.file_function_app.output_path)}.zip"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container.name
  type                   = "Block"
  source                 = data.archive_file.file_function_app.output_path
}

# Creating the SAS for connecting the function to the container
data "azurerm_storage_account_blob_container_sas" "storage_account_blob_container_sas" {
  connection_string = azurerm_storage_account.storage_account.primary_connection_string
  container_name    = azurerm_storage_container.storage_container.name

  start  = "2021-01-01T00:00:00Z"
  expiry = "2022-01-01T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}

# Create app service plan for azure function app
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.prefix_name}-app-service-plan"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.region
  kind                = "FunctionApp"
  reserved            = true
  sku {
    tier = "Premium V2"
    size = "P1v2"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Create the function app
resource "azurerm_function_app" "function_app" {
  depends_on = [
    azurerm_storage_account.storage_account
  ]
  name                = "${var.prefix_name}-function-app"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.region
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "https://${azurerm_storage_account.storage_account.name}.blob.core.windows.net/${azurerm_storage_container.storage_container.name}/${azurerm_storage_blob.storage_blob.name}${data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas}",
    "FUNCTIONS_WORKER_RUNTIME" = "node",
    "CosmosDbConnectionString" = "${var.connection_string}"
  }
  os_type = "linux"

  site_config {
    linux_fx_version          = null
    use_32_bit_worker_process = false
    cors {
      allowed_origins = ["*"]
    }
    # IP Restrictions are valid with consume tier, while function vnet integration is only available with elastic tier
    # ip_restriction {
    #   virtual_network_subnet_id = var.private_subnet
    # }
  }
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~3"

  auth_settings {
    enabled = true
    # "For applications that use Azure AD v1 and for Azure Functions apps, omit /v2.0 in the URL."
    # https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad#-enable-azure-active-directory-in-your-app-service-app
    issuer           = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
    default_provider = "AzureActiveDirectory"
    active_directory {
      client_id = azuread_application.ad_application_function_app.application_id
    }
    unauthenticated_client_action = "RedirectToLoginPage"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
#   app_service_id = azurerm_function_app.function_app.id
#   subnet_id      = var.intra_subnet
# }

resource "azuread_application" "ad_application_function_app" {
  display_name            = "${var.prefix_name}-ad-application-function-app"
  type                    = "webapp/api"
  prevent_duplicate_names = true
}

data "azurerm_client_config" "current" {
}

