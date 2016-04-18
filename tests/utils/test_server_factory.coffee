'use strict'

# requires
decache = require "decache"
express = require "express"
session = require "express-session"
bodyParser = require "body-parser"
routes = require "../../server/routes"
http = require "http"
cors = require "cors"


applicationBuilder =
  provide: (modules) ->
    app = express()
    router = express.Router()
    app.ioc = modules

    app.set "port", process.env.port or 3001
    app.set "env", process.env.NODE_ENV or "test"

    app.use cors()
    app.use bodyParser.urlencoded(extended: false)
    app.use bodyParser.json()
    routes app, router

    # Start server
    server = http.createServer(app)
    server.listen app.get("port")
    return {app: app, server: server}

  getDefaultIoc: ->
    decache('electrolyte')
    ioc = require 'electrolyte'
    ioc.use(ioc.node_modules())
    ioc.use('controllers', ioc.node('server/controllers'))
    ioc.use('models', ioc.node('server/models'))
    ioc.use('helpers', ioc.node('server/helpers'))
    ioc.use('middlewares', ioc.node('server/middlewares'))
    ioc.use(ioc.node('dist/components'))
    ioc.use(ioc.node('tests/utils'))
    return ioc


module.exports = applicationBuilder