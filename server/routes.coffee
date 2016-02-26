"use strict"
authController        = require './controllers/auth_controller'
meetingController     = require './controllers/meeting_controller'
passport              = require './authentication'
morgan                = require 'morgan'
googleapis            = require 'googleapis'
config                = require 'config'
User                  = require './models/user'
db                    = require './database_adapter'

module.exports = (app, router) ->
  app.use passport.initialize()
  app.use morgan('combined')
  app.use "/api/v1", router

  password = passport.authenticate 'password', { session: false }
  bearer = passport.authenticate 'bearer', { session: false }
  google = passport.authenticate 'google', { accessType: 'offline'}
  googleReturn = passport.authenticate('google',
    successRedirect: '/'
    failureRedirect: '/login')

  app.get "/", (req, res) ->
    res.status(200).send "TandemApi"

  # Login/logout Routes
  router.route "/login"
    .post (req, res) ->
      authController.google(req, res)

  router.route "/logout"
    #this route is only useful for session based auth
    .get authController.removeAuthentication, (req, res) ->
      res.status(200).send "Successfully logged out"

  router.route "/auth/google"
    .get google, (req,res) ->
      res.status(200).send req

  app.get "/auth/google/callback", googleReturn, (req,res) ->
    res.status(200).send 'woot'

  router.route "/calendar/:id"
    .get (req,res) ->
      calendar = googleapis.calendar('v3')
      User.methods.findOne { 'id': req.params.id }, (err, user) ->
        if err
          res.send(err)
        else
          OAuth2 = googleapis.auth.OAuth2
          oauth2Client = new OAuth2 config.googleAuthConfig.clientId, config.googleAuthConfig.clientSecret, config.googleAuthConfig.redirectUrl
          oauth2Client.setCredentials(user.auth)
          calendar.events.list {calendarId: 'primary', auth: oauth2Client}, (err,moo)->
            console.log(moo)
            # if err
            #   console.log 'The API returned an error: ' + err
            # else
            #   res.send(response.items)
          #   console.log user.auth
          null
          
          
        # b = User.methods.findById 


  # Meeting Routes
  router.route "/attendees"
    .post (req, res) ->
      meetingController.addEmail(req, res)
    .delete (req, res) ->
      meetingController.removeEmail(req, res)

  router.route "/meetings/"
    .post (req, res) ->
      meetingController.addMeeting(req, res)
