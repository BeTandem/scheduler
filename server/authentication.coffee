"use strict"

passport        = require 'passport'
localStrategy   = require('passport-local').Strategy
db              = require './database_adapter'


# Define Local Strategy
passport.use new localStrategy (username, password, done) ->
  console.log(username)
  console.log(password)
  if username == "admin@admin.com" && password == "password"
    console.log("correct!")
    return done null, { id: "112323124", message: 'Correct login!' }
  else
    return done null, false, { message: 'Incorrect login.' }


# Define Serialization
passport.serializeUser (user, done) ->
  console.log(user)
  done(null, user.id)

# Define Deserialization
passport.deserializeUser (id, done) ->
  console.log(id)
  # User.findById id, (err, user) ->
  #   done(err, user);


module.exports = passport
