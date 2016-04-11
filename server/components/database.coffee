'use strict'

exports = module.exports = (mongojs, config, logger) ->

  class Database
    constructor: ->
      dbConfig = config.get 'dbConfig'
      dbHost = dbConfig.host
      dbPort = dbConfig.port
      dbName = dbConfig.name
      logger.server "New Mongodb connection to "+dbName+"@"+dbHost
      @db = mongojs dbHost+":"+dbPort+"/"+dbName

    getDb: ->
      return @db

  database = new Database()
  return database.getDb()

exports['@singleton'] = true
exports['@require'] = ['mongojs', 'config', 'logger']