'use strict'

exports = module.exports = (googleAuth, CalendarParser, CalendarTokenizer, Meeting, User) ->

  meetingController =

    createMeeting: (req, res, next) ->
      initiatorUser = req.user

      # Builds Auth Client and Refreshes token if needed
      googleAuth.getAuthClient initiatorUser, (err, oauth2Client) ->
        if err then return next(err)

        # Gets the current Timezone at time of meeting creation
        googleAuth.getUserTimezone oauth2Client, (err, timezoneSetting) ->
          if err then return next(err)
          timezone = timezoneSetting.value

          # Create meeting in Database
          Meeting.methods.create {meeting_initiator: initiatorUser.email, timezone: timezone}, (err, meeting) ->

            # Build Response object
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
      # Simply returns the meeting added via middleware
      res.status(200).send(req.meeting)


    updateMeeting:(req, res, next) ->
      meeting_id = req.meeting._id
      lenInMin = req.body.length_in_min
      timezone = req.meeting.timezone


      # Update Meeting
      Meeting.methods.update meeting_id, req.body, (err, meeting) ->
        initiatorEmail = meeting.meeting_initiator
        emails = if meeting.emails then meeting.emails else []
        if !inEmailList initiatorEmail, emails
          emails.push initiatorEmail

        # Build Response Object
        UsersFromEmails emails, (err, users) ->
          if err then return next(err)
          googleAuth.getCalendarsFromUsers users, null, (err, cals) ->
            if err then return next(err)
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
      meeting = req.meeting
      meetingSummary = req.body.meeting_summary
      meetingLocation = req.body.meeting_location
      timeSelection = req.body.meeting_time_selection
      user = req.user

      # Builds Auth Client and Refreshes token if needed
      googleAuth.getAuthClient user, (err, oauth2Client) ->
        if err then return next(err)

        emailObjects = ({email: email} for email in meeting.emails)

        # Sends Meeting Invite
        meetingInfo =
          meetingSummary: meetingSummary
          meetingLocation: meetingLocation
          meetingAttendees: emailObjects
          timeSlot: timeSelection
        googleAuth.sendCalendarInvite oauth2Client, meetingInfo, (err, event) ->
          if err then return next(err)
          res.status(200).send(event)


    addAttendee: (req, res, next) ->
      meeting = req.meeting
      emailToAdd = req.body.email
      initiatorEmail = meeting.meeting_initiator
      emails = meeting.emails
      timezone = meeting.timezone
      lenInMin = meeting.length_in_min

      # Add new email if not already in emails list
      if emails
        if !inEmailList(emailToAdd, emails)
          emails.push emailToAdd
      else
        emails = [emailToAdd]

      # Add the emails to the meeting
      Meeting.methods.update meeting._id, {emails: emails}, (err) ->
        if err then next(err)
        # Append meeting initiatorEmail to schedule
        if !inEmailList initiatorEmail, emails
          emails.push initiatorEmail

        # Build out response object
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
      meeting = req.meeting
      emailToDelete = req.params.email
      initiator = meeting.meeting_initiator
      emails = meeting.emails
      timezone = meeting.timezone
      lenInMin = meeting.length_in_min

      # Remove email from email list if it exists
      if emails
        if inEmailList(emailToDelete, emails)
          index = emails.indexOf emailToDelete
          emails.splice(index, 1)

      # Update meeting with new emails list
      Meeting.methods.update meeting._id, {emails: emails}, (err) ->
        if err then return next(err)

        # Append meeting initiator to schedule
        emails = if emails then emails else []
        if !inEmailList initiator, emails
          emails.push initiator

        # Build out response object
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
      startDate = parseInt(req.params.startDate)

      # Append meeting initiator to schedule
      emails = if meeting.emails then meeting.emails else []
      console.log emails
      if !inEmailList initiator, emails
        emails.push initiator

      # Build out response object
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
