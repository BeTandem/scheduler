'use strict'

databaseAdapter = require '../database_adapter'
db = databaseAdapter.getDB()

# A smimple test controller to test the database adapter
testController =

  # a get request that returns all of the values in the test collection
  get: (req, res) ->
    db = databaseAdapter.getDB()
    return db.collection('test').find().toArray (err, result) ->
      res.status(200).send result

  # add a new document to the test collection
  post: (req, res) ->
    document = req.body
    db.collection('test').insert document, (err, result) ->
      res.status(200).send "Successful"

module.exports = testController
