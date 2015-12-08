"use strict"
testController = require './controllers/test_controller'
mentorController = require './controllers/mentor_controller'

module.exports = (app) ->

  app.get "/", (req, res) ->
    res.status(200).send "hello"

  # Test Route
  app.get "/test", (req, res) ->
    testController.get(req, res)

  app.post "/test", (req, res) ->
    testController.post(req, res)

  # Mentor Routes

  app.get "/api/v1/mentors", (req, res) ->
    mentorController.getMentors(req, res)

  app.get "/api/v1/mentors:id", (req, res) ->
    mentorController.getMentor(req, res)

  app.post "/api/v1/mentors", (req, res) ->
    mentorController.addMentor(req, res)

