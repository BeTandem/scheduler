"use strict"

# requires
express = require "express"
bodyParser = require "body-parser"
routes = require "./routes"
http = require "http"
cors = require "cors"
databaseAdapter = require('./database_adapter')

# Make app using Express framework
app = express()


app.set "port", process.env.PORT or 3000
app.set "env", process.env.NODE_ENV or "development"

app.use bodyParser.urlencoded(extended: false)
app.use bodyParser.json()
app.use cors() # TODO: change because allows all urls
routes app

# Start server
server = http.createServer(app)
server.listen app.get("port"), ->
  console.log "Listening on port " + app.get("port") + \
  " in " + app.get("env") + " mode"

# Export App
module.exports = app
