'use strict'

exports = module.exports = (googleAuth, CalendarParser, CalendarTokenizer, Meeting, User) ->

  meetingController =

    createMeeting: (req, res, next) ->
      initiator = req.user
      User.methods.findByGoogleId initiator.id, (err, initiatorUser) ->
        if err then return next(err)
        googleAuth.getAuthClient initiatorUser, (err, oauth2Client) ->
          if err then return next(err)
          googleAuth.getUserTimezone oauth2Client, (err, timezoneSetting) ->
            if err then return next(err)
            timezone = timezoneSetting.value
            Meeting.methods.create {meeting_initiator: initiator.email, timezone: timezone}, (err, meeting) ->
              googleAuth.getCalendarFreeBusy oauth2Client, null, (err, cals) ->
                if err then return next(err)
                calendarParser = new CalendarParser(timezone, 60)
                startDateTime = cals.timeMin
                availability = calendarParser.buildMeetingCalendar([cals], startDateTime)
                response = CalendarTokenizer.getCalendarPrevNextTokens(availability)
                response.calendar_hours = getCalendarTimes(calendarParser)
                response.meeting_id = meeting._id
                response.tandem_users = {name: initiatorUser.name, email: initiatorUser.email}
                response.schedule = availability
                res.status(200).send response

    getMeeting: (req, res, next) ->
      meeting_id = req.params.id
      Meeting.methods.findById meeting_id, (err, meeting) ->
        if err then return next(err)
        res.status(200).send(meeting)

    updateMeeting:(req, res, next) ->
      meeting_id = req.params.id
      lenInMin = req.body.length_in_min
      initiator = req.user

      timezoneFromUserId initiator.id, (err, timezone) ->
        if err then return next(err)
        req.body.timezone = timezone
        Meeting.methods.update meeting_id, req.body, (err, meeting) ->
          if err then return next(err)
          emails = [req.user.email]
          if req.body.attendees
            emails = emails.concat (attendee.email for attendee in req.body.attendees)
          UsersFromEmails emails, (err, users) ->
            if err then return next(err)
            googleAuth.getCalendarsFromUsers users, null, (err, cals) ->
#              if err then return next(new Error(err))
              calendarParser = new CalendarParser(timezone, lenInMin)
              startDateTime = cals[0].timeMin
              availability = calendarParser.buildMeetingCalendar(cals, startDateTime)
              response = CalendarTokenizer.getCalendarPrevNextTokens(availability)
              response.calendar_hours = getCalendarTimes(calendarParser)
              response.meeting_id = meeting._id
              response.tandem_users = ({name: user.name, email: user.email} for user in users)
              response.schedule = availability
              res.status(200).send response

    sendEmailInvites: (req, res, next) ->
      meeting_id = req.params.id or req.body.meeting_id
      meetingSummary = req.body.meeting_summary
      meetingLocation = req.body.meeting_location
      timeSelection = req.body.meeting_time_selection

      Meeting.methods.findById meeting_id, (err, meeting) ->
        if err then return next(err)
        user_id = req.user.id
        User.methods.findByGoogleId user_id, (err, user) ->
          if err then return next(err)
          googleAuth.getAuthClient user, (err, oauth2Client) ->
            if err then return next(err)
            emailsArr = (attendee for attendee in meeting.attendees)
            meetingInfo =
              meetingSummary: meetingSummary
              meetingLocation: meetingLocation
              meetingAttendees: emailsArr
              timeSlot: timeSelection
            googleAuth.sendCalendarInvite oauth2Client, meetingInfo, (err, event) ->
              if err then return next(err)
              res.status(200).send(event)

    addAttendee: (req, res, next) ->
      meeting_id = req.params.id
      email = req.body.email

      Meeting.methods.findById meeting_id, (err, doc) ->
        if err then return next(err)
        # Update the email list && save to meeting
        initiator = doc.meeting_initiator
        emails = doc.emails
        timezone = doc.timezone
        lenInMin = doc.length_in_mi
        if emails
          if !inEmailList(email, emails)
            emails.push email
        else
          emails = [email]

        Meeting.methods.update meeting_id, {emails: emails}, (err) ->
          if err then next(err)
          # Append meeting initiator to schedule
          if !inEmailList initiator, emails
            emails.push initiator

          # Build out calendar data
          UsersFromEmails emails, (err, users) ->
            if err then return next(err)
            googleAuth.getCalendarsFromUsers users, null, (err, cals) ->
              if err then return next(err)
              calendarParser = new CalendarParser(timezone, lenInMin)
              startDateTime = cals[0].timeMin
              availability = calendarParser.buildMeetingCalendar(cals, startDateTime)
              response = CalendarTokenizer.getCalendarPrevNextTokens(availability)
              response.calendar_hours = getCalendarTimes(calendarParser)
              response.tandem_users = ({name: user.name, email: user.email} for user in users)
              response.schedule = availability
              res.status(200).send response

    removeAttendee: (req, res, next) ->
      response = {}
      meeting_id = req.params.id
      email = req.params.email
      Meeting.methods.findById meeting_id, (err, doc) ->
        if err then return next(err)
        initiator = doc.meeting_initiator
        emails = doc.emails
        timezone = doc.timezone
        lenInMin = doc.length_in_min
        if emails
          if inEmailList(email, emails)
            index = emails.indexOf email
            emails.splice(index, 1)

        Meeting.methods.update meeting_id, {emails: emails}, (err) ->
          if err then return next(err)
          # Append meeting initiator to schedule
          if !inEmailList initiator, emails
            emails.push initiator

            UsersFromEmails emails, (err, users) ->
              if err then return next(err)
              googleAuth.getCalendarsFromUsers users, null, (err, cals) ->
                if err then return next(err)
                calendarParser = new CalendarParser(timezone, lenInMin)
                startDateTime = cals[0].timeMin
                availability = calendarParser.buildMeetingCalendar(cals, startDateTime)
                response = CalendarTokenizer.getCalendarPrevNextTokens(availability)
                response.calendar_hours = getCalendarTimes(calendarParser)
                response.tandem_users = ({name: user.name, email: user.email} for user in users)
                response.schedule = availability
                res.status(200).send response

    getNewCalendar: (req, res, next) ->
      meeting = req.meeting
      initiator = meeting.meeting_initiator
      emails = []
      if meeting.attendees
        emails = (attendee.email for attendee in meeting.attendees)
      startDate = parseInt(req.params.startDate)
      if !inEmailList initiator, emails
        emails.push initiator
      UsersFromEmails emails, (err, users) ->
        if err then return next(err)
        googleAuth.getCalendarsFromUsers users, startDate, (err, cals) ->
          if err then return next(err)
          calendarParser = new CalendarParser(meeting.timezone, meeting.length_in_min)
          availability = calendarParser.buildMeetingCalendar(cals, cals[0].timeMin)
          response = CalendarTokenizer.getCalendarPrevNextTokens(availability)
          response.calendar_hours = getCalendarTimes(calendarParser)
          response.schedule = availability
          res.status(200).send response


  # Private Helpers
  timezoneFromUserId = (id, callback) ->
    User.methods.findByGoogleId id, (err, initiatorUser) ->
      if err then return callback(err)
      googleAuth.getAuthClient initiatorUser, (err, oauth2Client) ->
        if err then return callback(err)
        googleAuth.getUserTimezone oauth2Client, (err, timezoneSetting) ->
          timezone = timezoneSetting.value
          callback(err, timezone)

  UsersFromEmails = (emails, callback) ->
    #collect google Ids from user db from emails
    User.methods.findByEmailList emails, callback

  inEmailList = (email, email_list) ->
    for e in email_list
      if email == e
        return true
    return false

  getCalendarTimes = (calendarParser) ->
    return {
      morning_start: calendarParser.morningStartHour
      morning_end: calendarParser.afternoonStartHour
      afternoon_start: calendarParser.afternoonStartHour
      afternoon_end: calendarParser.eveningStartHour
      evening_start: calendarParser.eveningStartHour
      evening_end: calendarParser.dayEndHour
    }

  return meetingController

exports['@require'] = [
  'helpers/auth/google',
  'helpers/calendar_parser',
  'helpers/calendar_tokenizer',
  'models/meeting',
  'models/user'
]
