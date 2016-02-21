"use strict"

# Use mongojs for database connections without callbacks
mongojs = require('mongojs')
config = require 'config'

# Load Database Configurations
dbConfig = config.get 'dbConfig'
dbHost = dbConfig.host
dbPort = dbConfig.port
dbName = dbConfig.name

Database = () ->
  # Store Connection for later use
  connection = null

  # Establish a new connection
  init = ->
    console.log "New Mongodb connection to "+dbName+"@"+dbHost
    _db = mongojs dbHost+":"+dbPort+"/"+dbName

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
