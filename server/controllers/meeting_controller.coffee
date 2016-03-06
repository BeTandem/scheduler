Meeting     = require "../models/meeting"
User        = require "../models/user"
googleAuth  = require "../helpers/auth/google"

meetingController =

  addEmail: (req, res) ->
    dummy_response = createDummyResponse()
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
        response.tandem_users = (user.email for user in users)
        if users.length
          response.schedule = dummy_response
        else
          response.schedule = []
        console.log(dummy_response)
        res.status(200).send response

  removeEmail: (req, res) ->
    dummy_response = createDummyResponse()
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
      res.status(200).send {dummy_response}

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

getRandomTrueFalse = () ->
  if Math.round(Math.random()*10)%2 == 1
    true
  else
    false

createDummyResponse = () ->
  return dummy_response = [
      day_code: 't'
      morning: getRandomTrueFalse()
      afternoon: getRandomTrueFalse()
      evening: getRandomTrueFalse()
    ,
      day_code: 'w'
      morning: getRandomTrueFalse()
      afternoon: getRandomTrueFalse()
      evening: getRandomTrueFalse()
    ,
      day_code: 'th'
      morning: getRandomTrueFalse()
      afternoon: getRandomTrueFalse()
      evening: getRandomTrueFalse()
    ,
      day_code: 'f'
      morning: getRandomTrueFalse()
      afternoon: getRandomTrueFalse()
      evening: getRandomTrueFalse()
    ,
      day_code: 'Sa'
      morning: getRandomTrueFalse()
      afternoon: getRandomTrueFalse()
      evening: getRandomTrueFalse()
  ]


module.exports = meetingController
