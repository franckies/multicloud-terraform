# Reference the backend application function
data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = "${path.module}/function-app"
  output_path = "function-app.zip"
}

# Create storage account holding the function code
resource "azurerm_storage_account" "storage_account" {
  name = "${replace(var.prefix_name, "-", "")}strg"
  resource_group_name = var.resource_group.name
  location = var.resource_group.region
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
    name = "${var.prefix_name}-storage-container-functions"
    storage_account_name = azurerm_storage_account.storage_account.name
    container_access_type = "private"
}

# Storage blob within the container holding the zip archive
resource "azurerm_storage_blob" "storage_blob" {
    name = "${filesha256(data.archive_file.file_function_app.output_path)}.zip"
    storage_account_name = azurerm_storage_account.storage_account.name
    storage_container_name = azurerm_storage_container.storage_container.name
    type = "Block"
    source = data.archive_file.file_function_app.output_path
}

# Creating the SAS for connecting the function to the container
data "azurerm_storage_account_blob_container_sas" "storage_account_blob_container_sas" {
  connection_string = azurerm_storage_account.storage_account.primary_connection_string
  container_name    = azurerm_storage_container.storage_container.name

  start = "2021-01-01T00:00:00Z"
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
    tier = "Dynamic"
    size = "Y1"
  }
}

# Create the function app
resource "azurerm_function_app" "function_app" {
  depends_on = [
    azurerm_storage_account.storage_account
  ]
  name                       = "${var.prefix_name}-function-app"
  resource_group_name        = var.resource_group.name
  location                   = var.resource_group.region
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"    = "https://${azurerm_storage_account.storage_account.name}.blob.core.windows.net/${azurerm_storage_container.storage_container.name}/${azurerm_storage_blob.storage_blob.name}${data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas}",
    "FUNCTIONS_WORKER_RUNTIME" = "node",
    # "AzureWebJobsDisableHomepage" = "true",
    # "WEBSITE_NODE_DEFAULT_VERSION": null
  }
  os_type = "linux"
  
  site_config {
    linux_fx_version          = null
    use_32_bit_worker_process = false
    cors {
      allowed_origins = [ "*" ]
    }
  }
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~3"
}


