db      = require("../database_adapter").getDB()
User = db.collection('user')

User.methods =

  findById: (id, callback) ->
    return User.find {
      _id: mongojs.ObjectId(id)
    }, (err, user) ->
      if err
        console.log "Find user by id error:", err
      if callback
        callback err, user

  addUser: (user, callback)->
    db.collection('user').insert user, (err, result) ->
      if err
        console.log "Add User error", err
      if callback
        callback err, result

  update: (id, data, callback) ->
    return User.findAndModify {
      query: {_id: mongojs.ObjectId(id)}
      update: { $set: data }
      new: true
      }, (err, result) ->
        if err
          console.log "Update user error:", err
        else if callback
          callback err, result

  findOne: (profileId, callback)->
    User.findOne profileId, (err, result) ->
      if err
        console.log "Find one user error:", err
      if callback
        callback err, result

  findByEmailList: (emails, callback) ->
    return User.find {
      email: {$in: emails}
    }, (err, users) ->
      if err
        console.log "Find user by email list error:", err
      if callback
        callback err, users

module.exports = User
