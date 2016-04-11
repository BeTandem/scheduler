'use strict'

exports = module.exports = () ->
  return new DatabaseMock()

class DatabaseMock
  constructor: ->
    console.log "Dude, you're getting a MockDB"
  collection: (collection) ->
    return {
      find: (something, callback) ->
        callback(null, "DUMMY DATA RETURNED!")
    }

exports['@singleton'] = true