"use strict"

passport        = require 'passport'
localStrategy   = require('passport-local').Strategy
bearerStrategy  = require('passport-http-bearer').Strategy
googleStrategy  = require('passport-google-oauth20').Strategy
authController  = require './controllers/auth_controller'
db              = require './database_adapter'
config          = require 'config'

# Define Local Strategy
passport.use 'password', new localStrategy (username, password, done) ->
  authController.validPassword(username, password, done)

# Bearer Strategy for Token-based Auth
passport.use 'bearer', new bearerStrategy (token, done) ->
  authController.validToken(token, done)

# Google Strategy
passport.use 'google', new googleStrategy({
	session: false
  clientID: config.googleAuthConfig.clientId
  clientSecret: config.googleAuthConfig.clientSecret
  callbackURL: config.googleAuthConfig.redirectUrl
  scope: [
    'openid'
    'email'
    'https://www.googleapis.com/auth/calendar'
  ]
}, (accessToken, refreshToken, profile, done) ->
	console.log('refreshToken', refreshToken);
  done null, profile
)


module.exports = passport
