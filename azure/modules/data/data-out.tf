output "account_name" {
  value = azurerm_cosmosdb_account.cosmos.name
}

output "db_name" {
  value = azurerm_cosmosdb_sql_database.sqldb.name
}

# output "lease_name" {
#   value = "${azurerm_cosmosdb_mongo_collection.counter.name}"
# }

output "connection_string" {
  value = azurerm_cosmosdb_account.cosmos.connection_strings[0]
}