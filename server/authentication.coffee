"use strict"

passport        = require 'passport'
localStrategy   = require('passport-local').Strategy
bearerStrategy  = require('passport-http-bearer').Strategy
authController  = require './controllers/auth_controller'
db              = require './database_adapter'

# Define Local Strategy
passport.use 'password', new localStrategy (username, password, done) ->
  authController.validPassword(username, password, done)

# Bearer Strategy for Token-based Auth
passport.use 'bearer', new bearerStrategy (token, done) ->
  authController.validToken(token, done)

module.exports = passport
