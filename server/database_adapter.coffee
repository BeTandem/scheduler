"use strict"

# Use mongoskin for database connections without callbacks
MongoClient = require('mongoskin').MongoClient
config = require 'config'

# Load Database Configurations
dbConfig = config.get 'dbConfig'
dbPort = dbConfig.port
dbHost = dbConfig.host
dbName = dbConfig.name

Database = () ->
  # Store Connection for later use
  connection = null

  # Establish a new connection
  init = ->
    url = 'mongodb://'+dbHost+':'+dbPort+"/"+dbName
    console.log("MongoClient: Initializing new connection to "+ url)
    _db = MongoClient.connect url

    # Return object for later expansion of methods
    return {
      getDB: ->
        return _db
    }

  return {
    # Singleton instance of database
    getInstance: ->
      if !connection
        connection = init()
      return connection
  }

module.exports = Database().getInstance()
