'use strict'

secrets = require('config').get 'secrets'
jwt     = require 'jsonwebtoken'

class Auth

  createToken: (userObject) ->
    return jwt.sign userObject,
      secrets.auth,
      {expiresIn: 7*24*60*60}

  verifyToken: (token, callback) ->
    jwt.verify token, secrets.auth, callback

module.exports = Auth