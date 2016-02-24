"use strict"

passport        = require 'passport'
localStrategy   = require('passport-local').Strategy
bearerStrategy  = require('passport-http-bearer').Strategy
googleStrategy  = require('passport-google-oauth20').Strategy
authController  = require './controllers/auth_controller'
db              = require './database_adapter'
config          = require 'config'
User            = require './models/user'


passport.serializeUser (user, done) ->
  console.log("USER ID",user._id)
  done null, user._id
passport.deserializeUser (id, done) ->
  console.log("id is", id)
  User.methods.findById id, (err, user) ->
    done err, user

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
  # done null, profile
  process.nextTick ->
    # try to find the user based on their google id
    User.methods.findOne { 'google_id': profile.id }, (err, user) ->
      if err
        return done err
      if user
        # if a user is found, log them in
        return done null, user
      else
        console.log('creating new user')
        # if the user isnt in our database, create a new user
        newUser = {}
        # set all of the relevant information
        newUser.google_id = profile.id
        newUser.google_accessToken = accessToken
        newUser.google_refreshToken = refreshToken
        newUser.google_name = profile.displayName
        newUser.google_email = profile.emails[0].value
        # pull the first email
        # save the user
        User.methods.addUser newUser, (err) ->
          if err
            throw err
          done null, newUser
)


module.exports = passport
