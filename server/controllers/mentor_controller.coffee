'use strict'

databaseAdapter = require '../database_adapter'
db = databaseAdapter.getDB()

# A smimple test controller to test the database adapter
MentorController =

  # a get request that returns single mentor
  getMentor: (req, res) ->
    # TODO: implement ID request
    return
    db = databaseAdapter.getDB()
    return db.collection('mentors').find().toArray (err, result) ->
      res.status(200).send result

  # a get request that returns all of the values in the mentors collection
  getMentors: (req, res) ->
    db = databaseAdapter.getDB()
    return db.collection('mentors').find().toArray (err, result) ->
      res.status(200).send result

  # add a new document to the test collection
  addMentor: (req, res) ->
    document = req.body
    db.collection('mentors').insert document, (err, result) ->
      res.status(200).send "Successful"

module.exports = MentorController
