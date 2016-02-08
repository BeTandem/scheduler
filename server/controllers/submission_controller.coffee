'use strict'
mongo             = require('mongoskin')
config            = require 'config'
databaseAdapter   = require '../database_adapter'
roomController    = require './room_controller'
mentorController  = require './mentor_Controller'
menteeController  = require './mentee_controller'
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
    user = req.user
    sendEmail(user)
    res.status(200).send "Successful"

sendEmail = (user) ->
  # Send Email that Urls have been submitted
  emailConfig = config.get 'emailConfig'
  transporter =
    nodemailer.createTransport emailConfig.smtp
  mailOptions =
    from: emailConfig.from
    to: emailConfig.to
    subject: 'There has been a schedule submission'
    text: 'Please check Tandem Scheduler for a submission from '+user.username
    html: '<b>Please check Tandem Scheduler for a submission from '+
      user.username + '</b>'

  transporter.sendMail mailOptions, (error, info) ->
    if error
      return console.log error
    console.log 'Message sent' + info.response

module.exports = SubmissionController
