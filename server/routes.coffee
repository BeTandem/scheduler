'use strict'

morgan = require 'morgan'

module.exports = (app, router) ->
  ioc = app.ioc
  passport = ioc.create 'middlewares/passport'
  validator = ioc.create 'helpers/validator'
  errorHandler = ioc.create 'helpers/error_handler'

  app.use passport.initialize()
  if process.env.NODE_ENV != 'test'
    app.use morgan('combined')
  app.use "/api/v1", router
  app.use errorHandler.handler

  bearer = passport.authenticate 'bearer', {session: false}

  app.get "/", (req, res) ->
    res.status(200).send "TandemApi"

  router.route "/user/login"
  .post (req, res, next) ->
    err = validator.validateType("login").getValidationErrors(req)
    if err
      next(err)
    else
      authController = ioc.create 'controllers/auth_controller'
      authController.googleLogin(req, res)

  router.route "/meeting"
  .get bearer, (req, res, next) ->
    (ioc.create 'controllers/meeting_controller').createMeeting(req, res, next)

  router.route "/meeting/:id"
  .get bearer, (req, res, next) ->
    ioc.create('controllers/meeting_controller').getMeeting(req, res, next)
  .put bearer, (req, res, next) ->
    err = validator.validateType("meeting").getValidationErrors(req)
    if err
      next(err)
    (ioc.create 'controllers/meeting_controller').updateMeeting(req, res, next)
  .post bearer, (req, res, next) ->
    err = validator.validateType("meeting").getValidationErrors(req)
    if err
      next(err)
    (ioc.create 'controllers/meeting_controller').sendEmailInvites(req, res, next)


  #############################################
  # Depricated Routes:
  ####################

  router.route "/login"
  .post (req, res, next) ->
    err = validator.validateType("login").getValidationErrors(req)
    if err
      next(err)
    else
      authController = ioc.create 'controllers/auth_controller'
      authController.googleLogin(req, res)

  # Meeting Routes
  router.route "/attendees"
  .post bearer, (req, res, next) ->
    err = validator.validateType("add_attendee").getValidationErrors(req)
    if err
      next(err)
    (ioc.create 'controllers/meeting_controller').addEmail(req, res)
  .delete bearer, (req, res, next) ->
    err = validator.validateType("delete_attendee").getValidationErrors(req)
    if err
      next(err)
    (ioc.create 'controllers/meeting_controller').removeEmail(req, res)

  router.route "/meetings/"
  .post bearer, (req, res, next) ->
    err = validator.validateType("meeting").getValidationErrors(req)
    if err
      next(err)
    req.params.id = req.body.id
    (ioc.create 'controllers/meeting_controller').updateMeeting(req, res)

  router.route "/sendMeetingInvite"
  .post bearer, (req, res, next) ->
    err = validator.validateType("schedule").getValidationErrors(req)
    if err
      next(err)
    (ioc.create 'controllers/meeting_controller').sendEmailInvites(req, res)
