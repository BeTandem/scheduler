"use strict"
testController    = require './controllers/test_controller'
mentorController  = require './controllers/mentor_controller'
passport          = require './authentication'

module.exports = (app, router) ->
  app.use passport.initialize()
  app.use passport.session()
  app.use "/api/v1", router

  app.get "/", (req, res) ->
    res.status(200).send "TandemApi"

  # Middleware for router
  router.use (req, res, next)->
    # visualize requests in terminal
    console.log('Making a ' + req.method + ' request to ' + req.url)
    next()

  # Login Routes
  router.route "/login"
    .post passport.authenticate('local'), (req, res) ->
      # console.log(res)
      res.status(200).send "yo"

  # Mentor Routes
  router.route "/mentors"
    .get (req, res) ->
      mentorController.getMentors(req, res)
    .post (req, res) ->
      mentorController.addMentor(req, res)

  router.get "/mentors/:mentor_id", (req, res) ->
    mentorController.getMentor(req, res)


