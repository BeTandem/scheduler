"use strict"
testController = require './controllers/test_controller'
mentorController = require './controllers/mentor_controller'

module.exports = (app, router) ->
  app.use "/api/v1", router

  app.get "/", (req, res) ->
    res.status(200).send "TandemApi"

  # Middleware for router
  router.use (req, res, next)->
    # visualize requests in terminal
    console.log('Making a ' + req.method + ' request to ' + req.url)
    next()

  # Test Route
  router.get "/test", (req, res) ->
    testController.get(req, res)

  router.post "/test", (req, res) ->
    testController.post(req, res)

  # Mentor Routes
  router.route "/mentors"
    .get (req, res) ->
      mentorController.getMentors(req, res)
    .post (req, res) ->
      mentorController.addMentor(req, res)

  router.route "/mentors/:mentor_id"
    .get (req, res) ->
      mentorController.getMentor(req, res)
    .post (req, res) ->
      mentorController.updateMentor(req, res)


