'use strict'

exports = module.exports = (passport, bearer, config, jwt) ->
  BearerStrategy = bearer.Strategy
  # Bearer Strategy for Token-based Auth
  passport.use 'bearer', new BearerStrategy (token, done) ->
    # verify the token
    jwt.verify token, config.secrets.auth, (err, decoded) ->
      if (err)
        return done err, false
      else
        decoded.token = token
        return done null, decoded
  return passport

exports['@require'] = ['passport', 'passport-http-bearer', 'config', 'jsonwebtoken']
