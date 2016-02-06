'use strict'
mongo = require('mongoskin')
databaseAdapter = require '../database_adapter'
db = databaseAdapter.getDB()

MenteeController =

  # returns single mentee by id
  getMentee: (req, res) ->
    mentee_id = req.params.mentee_id
    return db.collection('mentees')
      .find
        _id: mongo.helper.toObjectID(mentee_id)
      .toArray (err, result) ->
        if err
          console.log("ERROR: " + err)
          return res.send err
        res.status(200).send result

  # returns the mentees collection
  getMentees: (req, res) ->
    return db.collection('mentees')
      .find()
      .toArray (err, result) ->
        if err
          console.log "ERROR: " + err
          return res.send err
        res.status(200).send result

  # adds a new mentee to the mentee collection
  addMentee: (req, res) ->
    document = req.body
    db.collection('mentees')
      .insert document, (err, result) ->
        if err
          console.log "ERROR: " + err
          return res.send err
        res.status(200).send result.ops[0]

  # updates data for a mentee in the mentee collection
  updateMentee: (req, res) ->
    mentee_id = req.params.mentee_id
    document = req.body
    delete document._id
    db.collection('mentees')
      .update(
        {_id: mongo.helper.toObjectID(mentee_id)},
        document,
        (err, result) ->
          if err
            console.log "ERROR: " + err
            return res.send err
          res.status(200).send "Successful"
      )

  # deletes a mentee from the collection
  deleteMentee: (req, res) ->
    mentee_id = req.params.mentee_id
    db.collection('mentees')
      .remove(
        {_id: mongo.helper.toObjectID(mentee_id)},
        (err, result) ->
          if err
            console.log "ERROR: " + err
            return res.send err
          res.status(200).send "Successful"
      )


module.exports = MenteeController
