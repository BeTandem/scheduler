Meeting     = require "../models/meeting"
User        = require "../models/user"
googleAuth  = require "../helpers/auth/google"
config      = require 'config'
_           = require 'underscore'
moment      = require 'moment'
require 'moment-range'
require 'moment-timezone'

#constants
morningStartHour=8
afternoonStartHour=12
eveningStartHour=17
dayEndHour=20


meetingController =

  addEmail: (req, res) ->
    meeting_id = req.body.meeting_id
    email = req.body.email

    cursor = Meeting.methods.findById(meeting_id)
    cursor.on 'data', (doc) ->

      # Update the email list && save to meeting
      initiator = doc.meeting_initiator
      emails = doc.emails
      timezone = doc.timezone
      if emails
        if !inEmailList(email, emails)
          emails.push email
      else
        emails = [email]

      Meeting.methods.update(meeting_id, {emails: emails})

      # Append meeting initiator to schedule
      if !inEmailList initiator, emails
        emails.push initiator

      # Build out calendar data
      buildMeetingCalendar emails, timezone, (users, availability) ->
        response = {}
        response.tandem_users = ({name: user.name, email: user.email} for user in users)
        response.schedule = availability
        res.status(200).send response

  removeEmail: (req, res) ->
    response = {}
    meeting_id = req.query.meeting_id
    email = req.query.email
    cursor = Meeting.methods.findById(meeting_id)
    cursor.on 'data', (doc) ->
      initiator = doc.meeting_initiator
      emails = doc.emails
      timezone = doc.timezone
      if emails
        if inEmailList(email, emails)
          index = emails.indexOf email
          emails.splice(index, 1)

      Meeting.methods.update(meeting_id, {emails: emails})

      # Append meeting initiator to schedule
      if !inEmailList initiator, emails
        emails.push initiator

      buildMeetingCalendar emails, timezone, (users, availability) ->
        response = {}
        response.tandem_users = ({name: user.name, email: user.email} for user in users)
        response.schedule = availability
        res.status(200).send response

  addMeeting: (req, res) ->
    initiator = req.user
    req.body.meeting_initiator = initiator.email

    User.methods.findByGoogleId initiator.id, (err, initiatorUser) ->
      googleAuth.getAuthClient initiatorUser, (oauth2Client) ->
        googleAuth.getUserTimezone oauth2Client, (timezoneSetting) ->
          timezone = timezoneSetting.value
          req.body.timezone = timezone
          Meeting.methods.create req.body, (meeting) ->
            emails = [req.user.email]
            buildMeetingCalendar emails, timezone, (users, availability) ->
              response = {}
              response.meeting_id = meeting._id
              response.tandem_users = ({name: user.name, email: user.email} for user in users)
              response.schedule = availability
              res.status(200).send response



  sendEmailInvites: (req, res) ->
    meeting_id = req.body.meeting_id
    meetingSummary = req.body.meeting_summary
    meetingLocation = req.body.meeting_location
    timeSelections = req.body.meeting_time_selection

    cursor = Meeting.methods.findById meeting_id
    user_id = req.user.id
    User.methods.findByGoogleId user_id, (err, user) ->
      googleAuth.getAuthClient user, (oauth2Client) ->
        cursor.on 'data', (doc) ->
          emailsArr = []
          for email in doc.emails
            toPush = {email}
            emailsArr.push toPush

          #randomly choose time slot
          slot = timeSelections[Math.floor(Math.random() * (timeSelections.length-1))]

          meetingInfo =
            meetingSummary: meetingSummary
            meetingLocation: meetingLocation
            meetingAttendees: emailsArr
            timeSlot: slot
          googleAuth.sendCalendarInvite oauth2Client, meetingInfo, (event) ->
            res.status(200).send(event)


# Private Helpers
buildMeetingCalendar = (emails, timezone, callback) ->
  relCals = []
  freeBusy = []
  UsersFromEmails emails, (err, users) ->
    googleAuth.getCalendarsFromUsers users, (cals) ->
      for calObject in cals
        for name, calendar of calObject.calendars
          relCals.push calendar
      for times in relCals
        freeBusy.push times.busy
      freeBusy = _.flatten freeBusy

      groupAvailability = getAvailabilityRanges(freeBusy, timezone)
      if callback
        callback(users, groupAvailability)

getAvailabilityRanges = (timesArray, timezone) ->
  #TODO: move length into passed var
  lengthOfMeeting = 60 #in minutes
  duration = moment.duration(lengthOfMeeting, 'minutes')

  # Build Busy Ranges
  busyRanges = []
  for busy in timesArray
    start = moment(busy.start)
    end = moment(busy.end)
    range = moment.range(start, end)
    busyRanges.push(range)

  #Build Out fifteen min range for iteration
  now = moment()
  fifteenMinutes = moment.duration(15, 'minutes')
  newTime =  moment(now).add(fifteenMinutes)
  fifteenMinRange = moment.range(now, newTime)

  #retrieve relevant calendar chunks
  calendarChunks = createWeekCalendarChunks(timezone)

  availableRanges = []
  for day in calendarChunks
    dayObj =
      day_code: day.day_code
    delete day['day_code']

    for key, timeRange of day
      dayObj[key] = []
      if timeRange
        timeRange.by fifteenMinRange, (time) ->
          newRange = moment.range(time, moment(time).add(duration, 'minutes'))
          if isTimeRangeAvailable(newRange, busyRanges)
            dayObj[key].push(newRange)

    availableRanges.push(dayObj)

  return availableRanges

createWeekCalendarChunks = (timezone) ->
  calendarChunks = []


  # Get Range
  nowTime = moment()
  weekFromNow = moment(nowTime).add(moment.duration(4, 'days'))
  week = moment.range(nowTime, weekFromNow)

  #iterate through days to create time chunks
  week.by 'days', (day)->
    dayObj =
      day_code: day.format('dd')
      morning: null
      afternoon: null
      evening: null

    utcTimes = getUTCTimesFromTimezone(day, timezone)

    #create morning Range

    mornStart = utcTimes.mornStart
    mornEnd = utcTimes.aftStart
    morning = moment.range(mornStart, mornEnd)
    if nowTime.unix() < mornStart.unix()
      dayObj.morning = morning

    #create afternoon Range
    aftStart = utcTimes.aftStart
    aftEnd = utcTimes.evStart
    afternoon = moment.range(aftStart, aftEnd)
    if nowTime.unix() < aftStart.unix()
      dayObj.afternoon = afternoon

    #create evening Range
    evStart = utcTimes.evStart
    evEnd =utcTimes.evEnd
    evening = moment.range(evStart, evEnd)
    if nowTime.unix() < evStart.unix()
      dayObj.evening = evening

    calendarChunks.push dayObj

  return calendarChunks

isTimeRangeAvailable = (range, busyRanges) ->
  for busy in busyRanges
    if range.overlaps(busy)
      return false
  return true

UsersFromEmails = (emails, callback) ->
  #collect google Ids from user db from emails
  User.methods.findByEmailList emails, callback

inEmailList = (email, email_list) ->
  for e in email_list
    if email == e
      return true
  return false

getUTCTimesFromTimezone = (day, timezone) ->
  time =
    year: day.year()
    month: day.month()
    day: day.date()

  utcTimes = {}
  time.hour = morningStartHour
  utcTimes.mornStart = moment.tz(time, timezone)
  time.hour = afternoonStartHour
  utcTimes.aftStart = moment.tz(time, timezone)
  time.hour = eveningStartHour
  utcTimes.evStart = moment.tz(time, timezone)
  time.hour = dayEndHour
  utcTimes.evEnd = moment.tz(time, timezone)

  return utcTimes

module.exports = meetingController
