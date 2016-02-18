"use strict"
roomController        = require './controllers/room_controller'
mentorController      = require './controllers/mentor_controller'
menteeController      = require './controllers/mentee_controller'
submissionController  = require './controllers/submission_controller'
authController        = require './controllers/auth_controller'
passport              = require './authentication'
morgan                = require 'morgan'

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

  router.route "/mentors/:mentor_id"
    .get bearer, (req, res) ->
      mentorController.getMentor(req, res)
    .post bearer, (req, res) ->
      mentorController.updateMentor(req, res)
    .delete bearer, (req, res) ->
      mentorController.deleteMentor(req, res)

  # Room Routes
  router.route "/rooms"
    .get bearer, (req, res) ->
      roomController.getRooms(req, res)
    .post bearer, (req, res) ->
      roomController.addRoom(req, res)

  router.route "/rooms/:room_id"
    .get bearer, (req, res) ->
      roomController.getRoom(req, res)
    .post bearer, (req, res) ->
      roomController.updateRoom(req, res)
    .delete bearer, (req, res) ->
      roomController.deleteRoom(req, res)

  # Mentee Routes
  router.route "/mentees"
    .get bearer, (req, res) ->
      menteeController.getMentees(req, res)
    .post bearer, (req, res) ->
      menteeController.addMentee(req, res)

  router.route "/mentees/:mentee_id"
    .get bearer, (req, res) ->
      menteeController.getMentee(req, res)
    .post bearer, (req, res) ->
      menteeController.updateMentee(req, res)
    .delete bearer, (req, res) ->
      menteeController.deleteMentee(req, res)

  # Submission Routes
  router.route "/submissions"
    .get bearer, (req, res) ->
      submissionController.getSubmissions(req, res)
    .post bearer, (req, res) ->
      submissionController.addSubmission(req, res)
