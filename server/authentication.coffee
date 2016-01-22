"use strict"

passport        = require 'passport'
localStrategy   = require('passport-local').Strategy
bearerStrategy  = require('passport-http-bearer').Strategy
authController  = require './controllers/auth_controller'
db              = require './database_adapter'

# Bearer Strategy for Token-based Auth
passport.use new bearerStrategy (token, done) ->
  authController.validToken(token, done)

# Define Local Strategy
passport.use new localStrategy (username, password, done) ->
  authController.validPassword(username, password, done)

# Define Serialization
passport.serializeUser (user, done) ->
  done(null, user.token)

# Define Deserialization
passport.deserializeUser (token, done) ->
  # Actually decodes token using JWT
  authController.validToken(token, done)

module.exports = passport
