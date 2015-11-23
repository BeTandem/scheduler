"use strict"
express = require "express"
bodyParser = require "body-parser"
routes = require "./routes"
http = require "http"
app = express()

db = require './databaseAdapter'
db.InitDB()

# Make app using Express framework
app.set "port", process.env.PORT or 3000

app.set "env", process.env.NODE_ENV or "development"

app.use bodyParser.urlencoded(extended: false)
app.use bodyParser.json()
routes app

server = http.createServer(app)
server.listen app.get("port"), ->
  console.log "Listening on port " + app.get("port") + \
  " in " + app.get("env") + " mode"
module.exports = app
