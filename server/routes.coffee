"use strict"
mentorController  = require './controllers/mentor_controller'
authController    = require './controllers/auth_controller'
passport          = require './authentication'
morgan            = require 'morgan'

module.exports = (app, router) ->
  app.use passport.initialize()
  app.use morgan('combined')
  app.use "/api/v1", router

  password = passport.authenticate 'password', { session: false }
  bearer = passport.authenticate 'bearer', { session: false }

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

  # Mentor Routes
  router.route "/mentors"
    .get bearer, (req, res) ->
      mentorController.getMentors(req, res)
    .post bearer, (req, res) ->
      mentorController.addMentor(req, res)

  router.get "/mentors/:mentor_id", (req, res) ->
    mentorController.getMentor(req, res)


