# Cosmos DB Account
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "${var.prefix_name}-cosmos"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.region
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = false

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = var.resource_group.region
    failover_priority = 0
  }

  # Default is MongoDB 3.2, use capabilities to enable MongoDB 3.6
  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/4757
  capabilities {
    name = "EnableMongo"
  }
}

# Cosmos DB Mongo Database
resource "azurerm_cosmosdb_mongo_database" "mongodb" {
  name                = "${var.prefix_name}-mongodb"
  resource_group_name = var.resource_group.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

# Cosmos DB Mongo Collection
resource "azurerm_cosmosdb_mongo_collection" "counter" {
  name                = "counter"
  resource_group_name = var.resource_group.name
  account_name        = azurerm_cosmosdb_mongo_database.mongodb.account_name
  database_name       = azurerm_cosmosdb_mongo_database.mongodb.name
  shard_key           = "_shardKey"
  throughput          = 400

  index { keys = ["id"] }
  index { keys = ["_id"] }
  index { keys = ["counter"] }
}
