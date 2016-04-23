'use strict'

exports = module.exports = (passport, bearer, config, jwt, User) ->
  BearerStrategy = bearer.Strategy
  # Bearer Strategy for Token-based Auth
  passport.use 'bearer', new BearerStrategy (token, done) ->
    # verify the token
    jwt.verify token, config.secrets.auth, (err, decoded) ->
      if err then return done err, false
      decoded.token = token
      User.methods.findByGoogleId decoded.id, (err, user) ->
        if err then return done err, false
        return done null, user
  return passport

exports['@require'] = ['passport', 'passport-http-bearer', 'config', 'jsonwebtoken', 'models/user']
