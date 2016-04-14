'use strict'

exports = module.exports = (mongojs, db, logger) ->
  Meeting = db.collection 'meeting'
  Meeting.methods =

    create: (meeting, callback) ->
      return Meeting.insert meeting, (err, result) ->
        if err
          logger.error("Meetings Model Error:", err)
        callback(err, result)

    findById: (id, callback) ->
      Meeting.findOne {
        _id: mongojs.ObjectId(id)
      }, (err, result) ->
        callback(err, result)

    update: (id, data, callback) ->
      Meeting.findAndModify {
        query: {_id: mongojs.ObjectId(id)}
        update: {$set: data}
        new: true
      }, (err, result) ->
        if err
          logger.error("Meetings Model Error:", err)
        callback(err, result)

  return Meeting

exports['@require'] = ['mongojs', 'database', 'logger']
