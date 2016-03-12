"use strict"
authController        = require './controllers/auth_controller'
meetingController     = require './controllers/meeting_controller'
calendarController    = require './controllers/calendar_controller'
passport              = require './middlewares/passport'
morgan                = require 'morgan'
googleapis            = require 'googleapis'
config                = require 'config'
User                  = require './models/user'
db                    = require './database_adapter'

module.exports = (app, router) ->
  app.use passport.initialize()
  app.use morgan('combined')
  app.use "/api/v1", router

  bearer = passport.authenticate 'bearer', { session: false }

  app.get "/", (req, res) ->
    res.status(200).send "TandemApi"

  # Login/logout Routes
  router.route "/login"
    .post (req, res) ->
      authController.googleLogin(req, res)

  router.route "/calendar/:id"
    .get (req,res) ->
      calendarController.getCalendarEvents(req,res)

  router.route   "/sendMeetingInvite"
    .post bearer, (req,res) ->
      meetingController.sendEmailInvites(req,res)

  # Meeting Routes
  router.route "/attendees"
    .post (req, res) ->
      meetingController.addEmail(req, res)
    .delete (req, res) ->
      meetingController.removeEmail(req, res)

  router.route "/meetings/"
    .post (req, res) ->
      meetingController.addMeeting(req, res)

  router.route "/test"
    .post (req,res) ->
      meetingController.buildMeetingCalendar(req,res,["alca5676@colorado.edu", "acampbell@twitter.com"])
