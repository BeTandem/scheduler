googleapis  = require 'googleapis'
config      = require 'config'
User        = require '../../models/user'
logger      = require '../logger'

oauth2 = googleapis.oauth2('v2')
calendar = googleapis.calendar('v3')

googleAuth =

  authenticate: (authCode, clientId, redirect_uri, callback) ->
    oauth2Client = buildAuthClient clientId, redirect_uri
    getAuthToken authCode, oauth2Client, (err, tokens) ->
      oauth2Client.setCredentials(tokens)
      if callback
        callback err, oauth2Client, tokens

  getUserInfo: (oauth2Client, callback) ->
    oauth2.userinfo.get {
      auth: oauth2Client
    }, (err, googleUser) ->
      if err
        logger.error "Googleapis User Info Error:", err
      if callback
        callback err, googleUser

  getCalendarEventsList: (oauth2Client, callback) ->
    calendar.events.list {
      calendarId: 'primary'
      auth: oauth2Client
    }, (err, events)->
      if err
        logger.error "Googleapis Calendar Events Error:", err
      if callback
        callback err, events

  getCalendarsFromUsers: (userList, callback) ->
    busyFreePromiseList = []
    for user in userList
      getStoredAuthClient user, (oauth2Client) ->
        if oauth2Client
          busyFreePromise = getCalendarFreeBusy(oauth2Client)
          busyFreePromiseList.push busyFreePromise

    Promise.all(busyFreePromiseList).then (eventsList) ->
      callback(eventsList)

  getAuthClient: (user, callback) ->
    return getStoredAuthClient user, (oauth2Client) ->
      if oauth2Client && callback
        callback oauth2Client

  sendCalendarInvite: (oauth2Client, meetingInfo, callback) ->
    event =
      summary: meetingInfo.meetingSummary,
      location: meetingInfo.meetingLocation,
      start:
        dateTime: meetingInfo.timeSlot.start
      end:
        dateTime: meetingInfo.timeSlot.end
      attendees: meetingInfo.meetingAttendees
      description: description

    calendar.events.insert {
      auth: oauth2Client
      calendarId: 'primary'
      resource: event
      sendNotifications: true
    }, (err, event) ->
      if err
        logger.error 'There was an error contacting the Calendar service: ', err
        return err
      logger.info 'Event created: ' + event.htmlLink
      if callback
        callback(event)

  getUserTimezone: (oauth2Client, callback) ->
    calendar.settings.get {
      auth: oauth2Client
      setting: "timezone"
    }, (err, settings) ->
      if err
        logger.error "GoogleApis settings error:", err
      if callback
        callback settings


# Private Methods
getStoredAuthClient = (user, callback) ->
  clientId = config.googleAuthConfig.clientId
  redirectUri = config.googleAuthConfig.redirectUri
  oauth2Client = buildAuthClient clientId, redirectUri
  if !user.auth
    logger.error "Googleapis Auth token not stored for:" + user.email
    return callback(null)

  oauth2Client.setCredentials user.auth

  # Need to refresh access token
  if user.auth.expiry_date < (new Date).getTime()
    logger.info("Refreshing Access Token")
    tokenPromise = refreshAccessToken(oauth2Client)
    tokenPromise.then (tokens)->
      User.methods.updateAuth user.id, tokens
      oauth2Client.setCredentials tokens
      if callback
        callback(oauth2Client)

  else
    if callback
      callback(oauth2Client)

getAuthToken = (authCode, oauth2Client, callback)->
  oauth2Client.getToken authCode, (err, tokens)->
    if err
      logger.error "Googleapis Token Error:", err
    if callback
      return callback err, tokens

refreshAccessToken = (oauth2Client) ->
  tokensPromise = new Promise (resolve, reject) ->
    oauth2Client.refreshAccessToken (err, tokens)->
      if err
        logger.error "Refresh Access Token Error:", err
        reject(err)
      else
        resolve(tokens)
  return tokensPromise

buildAuthClient = (clientId, redirectUri)->
  secret = config.googleAuthConfig.clientSecret
  OAuth2 = googleapis.auth.OAuth2
  oauth2Client = new OAuth2 clientId, secret, redirectUri
  return oauth2Client

getCalendarIds = (oauth2Client, callback) ->
  calendar.calendarList.list {
    auth: oauth2Client
    minAccessRole: 'owner'
  }, (err, calendarIds) ->
    if err
      logger.error "Get Calendar Ids Error:", err
    if callback
      callback(err, calendarIds)

getEventsCalendar = (calendarId, oauth2Client)->
  return new Promise (resolve, reject)->
    calendar.events.list {
      calendarId: calendarId || 'primary'
      auth: oauth2Client
    }, (err, events) ->
      if err
        logger.error "Googleapis Get Users Calendars Error", err
        reject(err)
      else
        resolve(events)

getCalendarFreeBusy = (oauth2Client) ->
  today = new Date()
  weekFromToday = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)
  return new Promise (resolve, reject) ->
    getCalendarIds oauth2Client, (err, calendarList) ->
      if err
        reject err
      calendarIds = ({id: cal.id} for cal in calendarList.items)
      calendar.freebusy.query {
        resource:
          timeMin: today.toISOString()
          timeMax: weekFromToday.toISOString()
          items: calendarIds
        auth: oauth2Client
      }, (err, busyFree)->
        if err
          logger.error "Googleapis Calendar Events Error:", err
          reject err
        else
          resolve busyFree

description = "<div class=\"container\" style=\"width: 320px; margin-top: 40px; padding: 10px 10px; background-color: #d9d9d9; border-radius: 6px; text-align: center;\">\n<h4 style=\"margin-bottom: 0;\">This meeting was scheduled with</h4>\n<h2 style=\"margin-top: 0; margin-bottom: 30px;\">Tandem Scheduler</h2>\n<p style=\"text-align: center;\">Do you want to schedule meetings in <strong>less than 30</strong> seconds?<br/><br/>\n    <a href=\"https://betandem.com\" target=\"_blank\">Learn More</a> | <a href=\"https://beta.betandem.com\" target=\"_blank\">Try out our beta!</a>\n</p>\n<h6 style=\"margin-top:10px; text-align:center;\">Have feedback to make Tandem better? &nbsp;<a href=\"mailto:tandemscheduler@gmail.com?subject=Tandem Scheduler Feedback\">Send us a messsage</a></h6>\n</div>\n"

module.exports = googleAuth
