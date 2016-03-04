Meeting     = require "../models/meeting"
User        = require "../models/user"
googleAuth  = require "../helpers/auth/google"

meetingController =

  addEmail: (req, res) ->
    meeting_id = req.body.meeting_id
    email = req.body.email
    cursor = Meeting.methods.findById(meeting_id)
    cursor.on 'data', (doc) ->

      # Update the email list && save to meeting
      emails = doc.emails
      if emails
        if !inEmailList(email, emails)
          emails.push email
      else
        emails = [email]
      Meeting.methods.update(meeting_id, {emails:emails})

      # Build out calendar data
      UsersFromEmails emails, (err, users) ->
        collectschedules users, (schedules) ->
          console.log schedules



      res.status(200).send "schedule data goes here"

  removeEmail: (req, res) ->
    meeting_id = req.query.meeting_id
    email = req.query.email
    cursor = Meeting.methods.findById(meeting_id)
    cursor.on 'data', (doc) ->
      emails = doc.emails
      if emails
        if inEmailList(email, emails)
          index = emails.indexOf email
          emails.splice(index, 1)
      Meeting.methods.update(meeting_id, {emails:emails})
      res.status(200).send "schedule data goes here"

  addMeeting: (req, res) ->
    Meeting.methods.create req.body, (result) ->
      res.status(200).send result

# Private Helpers
UsersFromEmails = (emails, callback) ->
  #collect google Ids from user db from emails
  User.methods.findByEmailList emails, callback

collectschedules = (users, callback) ->
  if users.length
    googleAuth.getCalendarsFromusers(users, [], 0, callback)

buildMeetingCalendar = (calendars) ->
  # Build the calendar availability

inEmailList = (email, email_list) ->
  for e in email_list
    if email == e
      return true
  return false

module.exports = meetingController
