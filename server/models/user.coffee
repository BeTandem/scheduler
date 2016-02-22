bcrypt  = require "bcrypt"
db      = require("../database_adapter").getDB()

User = db.collection('user')

User.methods =
  generateHash: (password)->
    return bcrypt.hashSync(password, bcrypt.genSaltSync(8))

  validPassword: (password, hash)->
    return bcrypt.compareSync(password, hash)

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

  findOne: (profileId, callback)->
    User.findOne profileId, (err, result) ->
      if err
        console.log(err)
      if callback
        callback err, result
module.exports = User
