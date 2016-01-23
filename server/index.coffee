"use strict"

# requires
express         = require "express"
session         = require "express-session"
bodyParser      = require "body-parser"
routes          = require "./routes"
http            = require "http"
cors            = require "cors"
databaseAdapter = require('./database_adapter')

# Make app using Express framework
app = express()
router = express.Router()

app.set "port", process.env.PORT or 3000
app.set "env", process.env.NODE_ENV or "development"

app.use cors() # TODO: change because allows all urls
app.use bodyParser.urlencoded(extended: false)
app.use bodyParser.json()
routes app, router

# Start server
server = http.createServer(app)
server.listen app.get("port"), ->
  console.log "Listening on port " + app.get("port") + \
  " in " + app.get("env") + " mode"

# Export App
module.exports = app
