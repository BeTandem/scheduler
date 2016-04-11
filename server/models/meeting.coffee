'use strict'

exports = module.exports = (mongojs, db, logger) ->
  Meeting = db.collection 'meeting'
  Meeting.methods =

    create: (meeting, callback) ->
      return Meeting.insert meeting , (err, result) ->
        if err
          logger.error("Meetings Model Error:", err)
        else if callback
          callback(result)

    findById: (id, callback) ->
      return Meeting.find {
        _id: mongojs.ObjectId(id)
        }

    update: (id, data, callback) ->
      return Meeting.findAndModify {
        query: {_id: mongojs.ObjectId(id)}
        update: { $set: data }
        new: true
        }, (err, result) ->
          if err
            logger.error("Meetings Model Error:", err)
          else if callback
            callback(result)

  return Meeting

exports['@require'] = ['mongojs', 'database', 'logger']
