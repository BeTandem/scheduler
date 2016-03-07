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
          console.log "SCHEDULES", schedules
        response = {}
        response.tandem_users = ({name: user.name, email: user.email} for user in users)
        if users.length
          response.schedule = dummy_response
        else
          console.log("hello")
          response.schedule = []
        res.status(200).send response

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
      res.status(200).send dummy_response

  addMeeting: (req, res) ->
    Meeting.methods.create req.body, (result) ->
      res.status(200).send result

# Private Helpers
UsersFromEmails = (emails, callback) ->
  #collect google Ids from user db from emails
  User.methods.findByEmailList emails, callback

collectschedules = (users, callback) ->
  if users.length
    googleAuth.getCalendarsFromUsers(users, callback)

buildMeetingCalendar = (calendars) ->
  # Build the calendar availability

inEmailList = (email, email_list) ->
  for e in email_list
    if email == e
      return true
  return false

dummy_response = [
      day_code: 't'
      morning: true
      afternoon: false
      evening: false
    ,
      day_code: 'w'
      morning: true
      afternoon: false
      evening: true
    ,
      day_code: 'th'
      morning: false
      afternoon: true
      evening: true
    ,
      day_code: 'f'
      morning: true
      afternoon: false
      evening: false
    ,
      day_code: 'Sa'
      morning: false
      afternoon: false
      evening: false
  ]


module.exports = meetingController
