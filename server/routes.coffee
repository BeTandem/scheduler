"use strict"
mentorController  = require './controllers/mentor_controller'
authController    = require './controllers/auth_controller'
passport          = require './authentication'
morgan            = require 'morgan'

module.exports = (app, router) ->
  app.use passport.initialize()
  app.use passport.session()
  app.use morgan('combined')
  app.use "/api/v1", router

  app.get "/", (req, res) ->
    res.status(200).send "TandemApi"

  # Login/logout Routes
  router.route "/login"
    .post passport.authenticate('local'), (req, res) ->
      res.status(200).send req.user

  router.route "/logout"
    .get authController.removeAuthentication, (req, res) ->
      res.status(200).send "Successfully logged out"

  # Mentor Routes
  router.route "/mentors"
    .get authController.authenticate, (req, res) ->
      mentorController.getMentors(req, res)
    .post (req, res) ->
      mentorController.addMentor(req, res)

  router.get "/mentors/:mentor_id", (req, res) ->
    mentorController.getMentor(req, res)


