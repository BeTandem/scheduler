"use strict"
authController        = require './controllers/auth_controller'
meetingController     = require './controllers/meeting_controller'
calendarController    = require './controllers/calendar_controller'
passport              = require './middlewares/passport'
morgan                = require 'morgan'
googleapis            = require 'googleapis'
config                = require 'config'
Validator             = require './helpers/validator'
ErrorHandler          = require './helpers/error_handler'

validator = new Validator()
errorHandler = new ErrorHandler()

module.exports = (app, router) ->
  app.use passport.initialize()
  if process.env.NODE_ENV != 'test'
    app.use morgan('combined')
  app.use "/api/v1", router
  app.use errorHandler.handler

  bearer = passport.authenticate 'bearer', { session: false }

  app.get "/", (req, res) ->
    res.status(200).send "TandemApi"

  # Login/logout Routes
  router.route "/login"
    .post (req, res, next) ->
      err = validator.validateType("login").getValidationErrors(req)
      if err
        next(err)
      else
        authController.googleLogin(req, res)

  # Meeting Routes
  router.route "/attendees"
    .post bearer, (req, res, next) ->
      err = validator.validateType("add_attendee").getValidationErrors(req)
      if err
        next(err)
      meetingController.addEmail(req, res)
    .delete bearer, (req, res, next) ->
      err = validator.validateType("delete_attendee").getValidationErrors(req)
      if err
        next(err)
      meetingController.removeEmail(req, res)

  router.route "/meetings/"
    .post bearer, (req, res, next) ->
      err = validator.validateType("meeting").getValidationErrors(req)
      if err
        next(err)
      meetingController.addMeeting(req, res)

  router.route   "/sendMeetingInvite"
    .post bearer, (req, res, next) ->
      err = validator.validateType("schedule").getValidationErrors(req)
      if err
        next(err)
      meetingController.sendEmailInvites(req,res)

  # Testing Routes
  router.route "/calendar/:id"
    .get (req,res) ->
      calendarController.getCalendarEvents(req,res)