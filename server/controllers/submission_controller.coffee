'use strict'
mongo             = require('mongoskin')
config            = require 'config'
databaseAdapter   = require '../database_adapter'
# roomController    = require './room_controller'
# mentorController  = require './mentor_controller'
# menteeController  = require './mentee_controller'
nodemailer        = require 'nodemailer'
db = databaseAdapter.getDB()

SubmissionController =

  # returns single submission by id
  getSubmission: (req, res) ->
    submission_id = req.params.submission_id
    return db.collection('submissions')
      .find
        _id: mongo.helper.toObjectID(submission_id)
      .toArray (err, result) ->
        if err
          console.log("ERROR: " + err)
          return res.send err
        res.status(200).send result

  # returns the submissions collection
  getSubmissions: (req, res) ->
    return db.collection('submissions')
      .find()
      .toArray (err, result) ->
        if err
          console.log "ERROR: " + err
          return res.send err
        res.status(200).send result

  # adds a new submission to the submission collection
  addSubmission: (req, res) ->
    # Send Email that Urls have been submitted
    body = req.body
    user = req.user
    sendEmail(user, body)
    res.status(200).send "Successful"

sendEmail = (user, body) ->
  # Send Email that Urls have been submitted
  emailConfig = config.get 'emailConfig'
  transporter =
    nodemailer.createTransport emailConfig.smtp

  roomTable = "<table><tr><h2>Rooms</h2><tr>"
  roomTable += "<tr><th>Name</th><th>url</th><tr>"
  for room in body.rooms
    roomTable += "<tr><td>"+room.name+"</td><td>"+
      room.calendarUrl+"</td></tr>"
  roomTable += "</table>"

  mentorTable = "<table><tr><h2>Mentors</h2><tr>"
  mentorTable += "<tr><th>Name</th><th>url</th><tr>"
  for mentor in body.mentors
    mentorTable += "<tr><td>"+mentor.name+"</td><td>"+
      mentor.calendarUrl+"</td></tr>"
  mentorTable += "</table>"

  menteeTable = "<table><tr><h2>Mentees</h2><tr>"
  menteeTable += "<tr><th>Name</th><th>url</th><tr>"
  for mentee in body.mentees
    menteeTable += "<tr><td>"+mentee.name+"</td><td>"+
      mentee.calendarUrl+"</td></tr>"
  menteeTable += "</table>"

  emailBody = "<p>New Tandem Scheduler for a submission from "
  emailBody += user.username + "</p><br/><br/>"
  emailBody += roomTable + "<br/><br/>"
  emailBody += mentorTable + "<br/><br/>"
  emailBody += menteeTable

  console.log(emailBody)

  mailOptions =
    from: emailConfig.from
    to: emailConfig.to
    subject: 'There has been a schedule submission'
    text: 'Please check Tandem Scheduler for a submission from '+user.username
    html: emailBody

  transporter.sendMail mailOptions, (error, info) ->
    if error
      return console.log error
    console.log 'Message sent' + info.response

module.exports = SubmissionController
