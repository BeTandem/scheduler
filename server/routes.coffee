"use strict"
authController        = require './controllers/auth_controller'
meetingController     = require './controllers/meeting_controller'
passport              = require './authentication'
morgan                = require 'morgan'

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
    .post password, (req, res) ->
      res.status(200).send req.user

  router.route "/logout"
    #this route is only useful for session based auth
    .get authController.removeAuthentication, (req, res) ->
      res.status(200).send "Successfully logged out"

  router.route "/auth/google"
    .get google, (req,res) ->
      res.status(200).send req

  app.get "/auth/google/callback", googleReturn, (req,res) ->
    res.status(200).send 'woot'

  # Meeting Routes
  router.route "/attendees"
    .post (req, res) ->
      meetingController.addEmail(req, res)
    .delete (req, res) ->
      meetingController.removeEmail(req, res)

  router.route "/meetings/"
    .post (req, res) ->
      meetingController.addMeeting(req, res)
