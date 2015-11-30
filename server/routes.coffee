"use strict"
testController = require './controllers/test_controller'

module.exports = (app) ->

  app.get "/", (req, res) ->
    res.status(200).send "hello"

  # Test Route
  app.get "/test", (req, res) ->
    testController.get(req, res)

  app.post "/test", (req, res) ->
    testController.post(req, res)
