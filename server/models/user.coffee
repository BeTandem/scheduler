db      = require("../database_adapter").getDB()
User = db.collection('user')

User.methods =

  findById: (id, callback) ->
    return User.find {
      _id: mongojs.ObjectId(id)
      }

  addUser: (user, callback)->
    db.collection('user').insert user, (err, result) ->
      if err
        console.log(err)
      if callback
        callback err,result

  update: (id, data, callback) ->
    return Meeting.findAndModify {
      query: {_id: mongojs.ObjectId(id)}
      update: { $set: data }
      new: true
      }, (err, result) ->
        if err
          console.log(err)
        else if callback
          callback err, result

  findOne: (profileId, callback)->
    User.findOne profileId, (err, result) ->
      if err
        console.log(err)
      if callback
        callback err, result
module.exports = User
