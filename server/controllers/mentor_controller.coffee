'use strict'
mongo = require('mongoskin')
databaseAdapter = require '../database_adapter'
db = databaseAdapter.getDB()

MentorController =

  # returns single mentor by id
  getMentor: (req, res) ->
    mentor_id = req.params.mentor_id
    db = databaseAdapter.getDB()
    return db.collection('mentors')
      .find
        _id: mongo.helper.toObjectID(mentor_id)
      .toArray (err, result) ->
        if err
          res.send err
        res.status(200).send result

  # returns the mentors collection
  getMentors: (req, res) ->
    db = databaseAdapter.getDB()
    return db.collection('mentors')
      .find()
      .toArray (err, result) ->
        if err
          res.send err
        res.status(200).send result

  # adds a new mentor to the mentor collection
  addMentor: (req, res) ->
    document = req.body
    db.collection('mentors')
      .insert document, (err, result) ->
        if err
          res.send err
        res.status(200).send "Successful"

module.exports = MentorController
