Db = require('mongodb').Db
Server = require('mongodb').Server
dbPort = 27017
dbHost = 'localhost'
dbName = 'dev_db'

DataBase = ->
module.exports = DataBase

DataBase.GetDB = ->
  if typeof DataBase.db == 'undefined'
    DataBase.InitDB()
  DataBase.db

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

DataBase.Disconnect = ->
  if DataBase.db
    DataBase.db.close()
  return

DataBase.BsonIdFromString = (id) ->
  mongo = require 'mongodb'
  BSON = mongo.BSONPure
  new (BSON.ObjectID)(id)