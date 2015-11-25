"use strict"

# Requires
Db = require('mongodb').Db
Server = require('mongodb').Server
config = require 'config'

# Database setup
dbConfig = config.get 'dbConfig'
dbPort = dbConfig.port
dbHost = dbConfig.host
dbName = dbConfig.name

DataBase = {}

# Singleton instance of database
DataBase.GetDB = ->
  if typeof DataBase.db == 'undefined'
    DataBase.InitDB()
  DataBase.db

# Initialize database
DataBase.InitDB = (callback) ->
  if _curDB == null or _curDB == undefined or _curDB == ''
    _curDB = dbName
  DataBase.db = new Db(_curDB, new Server(dbHost, dbPort, {}, {}),
    safe: false
    auto_reconnect: true)
  DataBase.db.open (err, db) ->
    if err
      console.log err
    else
      console.log 'connected to database :: ' + _curDB
      if callback != undefined
        callback db
    return
  return

# Close database connection
DataBase.Disconnect = ->
  if DataBase.db
    DataBase.db.close()
  return

# Retrieve BSON Id
DataBase.BsonIdFromString = (id) ->
  mongo = require 'mongodb'
  BSON = mongo.BSONPure
  new (BSON.ObjectID)(id)

# Export Database Object
module.exports = DataBase
