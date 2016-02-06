'use strict'
mongo = require('mongoskin')
databaseAdapter = require '../database_adapter'
db = databaseAdapter.getDB()

RoomController =

  # returns single room by id
  getRoom: (req, res) ->
    room_id = req.params.room_id
    return db.collection('rooms')
      .find
        _id: mongo.helper.toObjectID(room_id)
      .toArray (err, result) ->
        if err
          console.log("ERROR: " + err)
          return res.send err
        res.status(200).send result

  # returns the rooms collection
  getRooms: (req, res) ->
    return db.collection('rooms')
      .find()
      .toArray (err, result) ->
        if err
          console.log "ERROR: " + err
          return res.send err
        res.status(200).send result

  # adds a new room to the room collection
  addRoom: (req, res) ->
    document = req.body
    db.collection('rooms')
      .insert document, (err, result) ->
        if err
          console.log "ERROR: " + err
          return res.send err
        res.status(200).send result.ops[0]

  # updates data for a room in the room collection
  updateRoom: (req, res) ->
    room_id = req.params.room_id
    document = req.body
    delete document._id
    db.collection('rooms')
      .update(
        {_id: mongo.helper.toObjectID(room_id)},
        document,
        (err, result) ->
          if err
            console.log "ERROR: " + err
            return res.send err
          res.status(200).send "Successful"
      )

  # deletes a room from the collection
  deleteRoom: (req, res) ->
    room_id = req.params.room_id
    db.collection('rooms')
      .remove(
        {_id: mongo.helper.toObjectID(room_id)},
        (err, result) ->
          if err
            console.log "ERROR: " + err
            return res.send err
          res.status(200).send "Successful"
      )


module.exports = RoomController
