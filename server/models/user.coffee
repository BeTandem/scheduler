bcrypt  = require "bcrypt"
db      = require("../database_adapter").getDB()

user = db.collection('user')

user.methods =
  generateHash: (password)->
    return bcrypt.hashSync(password, bcrypt.genSaltSync(8))

  validPassword: (password, hash)->
    return bcrypt.compareSync(password, hash)

  addUser: (user)->
    db.collection('user').insert user, (err, result) ->
      if err
        console.log(err)

module.exports = user
