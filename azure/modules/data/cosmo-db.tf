################################################################################
# Cosmos sql db
################################################################################
#account
resource "azurerm_cosmosdb_account" "cosmos" {
  name                      = "${var.prefix_name}-cosmos"
  resource_group_name       = var.resource_group.name
  location                  = var.resource_group.region
  offer_type                = "Standard"
  enable_automatic_failover = true
  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.resource_group.region
    failover_priority = 0
  }
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#database
resource "azurerm_cosmosdb_sql_database" "sqldb" {
  name                = "${var.prefix_name}-db"
  resource_group_name = var.resource_group.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = 400
}

#collection
resource "azurerm_cosmosdb_sql_container" "sqlcoll" {
  name                  = "coll"
  resource_group_name   = var.resource_group.name
  account_name          = azurerm_cosmosdb_account.cosmos.name
  database_name         = azurerm_cosmosdb_sql_database.sqldb.name
  throughput            = 400
  partition_key_path    = "/id"
  partition_key_version = 1
}