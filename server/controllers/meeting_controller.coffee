'use strict'

exports = module.exports = (googleAuth, CalendarParser, Meeting, User) ->

  meetingController =

    createMeeting: (req, res) ->
      initiator = req.user
      User.methods.findByGoogleId initiator.id, (err, initiatorUser) ->
        googleAuth.getAuthClient initiatorUser, (oauth2Client) ->
          googleAuth.getUserTimezone oauth2Client, (timezoneSetting) ->
            timezone = timezoneSetting.value
            Meeting.methods.create {meeting_initiator: initiator.email}, (meeting) ->
              googleAuth.getCalendarsFromUsers [initiatorUser], (cals) ->
                calendarParser = new CalendarParser(timezone, 60)
                availability = calendarParser.buildMeetingCalendar(cals)
                response = {}
                response.calendar_hours = getCalendarTimes(calendarParser)
                response.meeting_id = meeting._id
                response.tandem_users = {name: initiatorUser.name, email: initiatorUser.email}
                response.schedule = availability
                res.status(200).send response

    getMeeting: (req, res, next) ->
      meeting_id = req.params.id
      user_email = req.user.email
      Meeting.methods.findById meeting_id, (err, meeting) ->
        if err then return next(new Error(err))
        if user_email == meeting.meeting_initiator
          res.status(200).send(meeting)
        else
          res.status(401).send("You are not authorized to view this meeting")

    updateMeeting:(req, res, next) ->

      #TODO: make sure you can only update your own meetings!

      meeting_id = req.params.id
      lenInMin = req.body.length_in_min
      initiator = req.user

      timezoneFromUserId initiator.id, (err, timezone) ->
        if err then return next(new Error(err))
        req.body.timezone = timezone
        Meeting.methods.update meeting_id, req.body, (err, meeting) ->
          if err then return next(new Error(err))
          emails = [req.user.email]
          if req.body.attendees
            emails = emails.concat (attendee.email for attendee in req.body.attendees)
          UsersFromEmails emails, (err, users) ->
            if err then return next(new Error(err))
            googleAuth.getCalendarsFromUsers users, (cals) ->
              calendarParser = new CalendarParser(timezone, lenInMin)
              availability = calendarParser.buildMeetingCalendar(cals)
              response = {}
              response.calendar_hours = getCalendarTimes(calendarParser)
              response.meeting_id = meeting._id
              response.tandem_users = ({name: user.name, email: user.email} for user in users)
              response.schedule = availability
              res.status(200).send response

    sendEmailInvites: (req, res, next) ->
      meeting_id = req.params.id or req.body.meeting_id
      meetingSummary = req.body.meeting_summary
      meetingLocation = req.body.meeting_location
      timeSelections = req.body.meeting_time_selection

      Meeting.methods.findById meeting_id, (err, meeting) ->
        if err then return next(new Error(err))
        user_id = req.user.id
        User.methods.findByGoogleId user_id, (err, user) ->
          if err then return next(new Error(err))
          googleAuth.getAuthClient user, (oauth2Client) ->
            emailsArr = (attendee.email for attendee in meeting.attendees)

            #TODO: remove randomly choose time slot
            slot = timeSelections[Math.floor(Math.random() * (timeSelections.length-1))]

            meetingInfo =
              meetingSummary: meetingSummary
              meetingLocation: meetingLocation
              meetingAttendees: emailsArr
              timeSlot: slot
            googleAuth.sendCalendarInvite oauth2Client, meetingInfo, (event) ->
              res.status(200).send(event)

    addEmail: (req, res) ->
      meeting_id = req.body.meeting_id
      email = req.body.email

      Meeting.methods.findById meeting_id, (err, doc) ->

        # Update the email list && save to meeting
        initiator = doc.meeting_initiator
        emails = doc.emails
        timezone = doc.timezone
        lenInMin = doc.length_in_min
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
        UsersFromEmails emails, (err, users) ->
          googleAuth.getCalendarsFromUsers users, (cals) ->
            calendarParser = new CalendarParser(timezone, lenInMin)
            availability = calendarParser.buildMeetingCalendar(cals)
            response = {}
            response.calendar_hours = getCalendarTimes(calendarParser)
            response.tandem_users = ({name: user.name, email: user.email} for user in users)
            response.schedule = availability
            res.status(200).send response

    removeEmail: (req, res) ->
      response = {}
      meeting_id = req.query.meeting_id
      email = req.query.email
      Meeting.methods.findById meeting_id, (err, doc) ->
        initiator = doc.meeting_initiator
        emails = doc.emails
        timezone = doc.timezone
        lenInMin = doc.length_in_min
        if emails
          if inEmailList(email, emails)
            index = emails.indexOf email
            emails.splice(index, 1)

        Meeting.methods.update(meeting_id, {emails: emails})

        # Append meeting initiator to schedule
        if !inEmailList initiator, emails
          emails.push initiator

          UsersFromEmails emails, (err, users) ->
            googleAuth.getCalendarsFromUsers users, (cals) ->
              calendarParser = new CalendarParser(timezone, lenInMin)
              availability = calendarParser.buildMeetingCalendar(cals)
              response = {}
              response.calendar_hours = getCalendarTimes(calendarParser)
              response.tandem_users = ({name: user.name, email: user.email} for user in users)
              response.schedule = availability
              res.status(200).send response

    addMeeting: (req, res) ->
      initiator = req.user
      req.body.meeting_initiator = initiator.email

      lenInMin = req.body.length_in_min

      User.methods.findByGoogleId initiator.id, (err, initiatorUser) ->
        googleAuth.getAuthClient initiatorUser, (oauth2Client) ->
          googleAuth.getUserTimezone oauth2Client, (timezoneSetting) ->
            timezone = timezoneSetting.value
            req.body.timezone = timezone
            Meeting.methods.create req.body, (meeting) ->
              emails = [req.user.email]
              if req.body.attendees
                emails = emails.concat (attendee.email for attendee in req.body.attendees)
              UsersFromEmails emails, (err, users) ->
                googleAuth.getCalendarsFromUsers users, (cals) ->
                  calendarParser = new CalendarParser(timezone, lenInMin)
                  availability = calendarParser.buildMeetingCalendar(cals)
                  response = {}
                  response.calendar_hours = getCalendarTimes(calendarParser)
  #                logger.debug "cal hours", response.calendar_hours
                  response.meeting_id = meeting._id
                  response.tandem_users = ({name: user.name, email: user.email} for user in users)
                  response.schedule = availability
                  res.status(200).send response

  # Private Helpers
  timezoneFromUserId = (id, callback) ->
    User.methods.findByGoogleId id, (err, initiatorUser) ->
      googleAuth.getAuthClient initiatorUser, (oauth2Client) ->
        googleAuth.getUserTimezone oauth2Client, (timezoneSetting) ->
          timezone = timezoneSetting.value
          if callback then callback(err, timezone)

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

exports['@require'] = ['helpers/auth/google', 'helpers/calendar_parser', 'models/meeting', 'models/user']
