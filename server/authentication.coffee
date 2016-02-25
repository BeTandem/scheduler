"use strict"

passport        = require 'passport'
bearerStrategy  = require('passport-http-bearer').Strategy
authController  = require './controllers/auth_controller'
config          = require 'config'

# Bearer Strategy for Token-based Auth
passport.use 'bearer', new bearerStrategy (token, done) ->
  authController.validToken(token, done)

module.exports = passport
