googleapis  = require 'googleapis'
config      = require 'config'

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
        console.log "Googleapis User Info Error:", err
      if callback
        callback err, googleUser

  getCalendarEventsList: (oauth2Client, callback) ->
    calendar.events.list {
      calendarId: 'primary'
      auth: oauth2Client
    }, (err, events)->
      if err
        console.log "Googleapis Calendar Events Error:", err
      if callback
        callback err, events

  getCalendarFreeBusy: (oauth2Client, id, callback) ->
    today = new Date()
    weekFromToday = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)
    console.log weekFromToday.toString()
    calendar.freebusy.query {
      resource:
        timeMin: today.toISOString()
        timeMax: weekFromToday.toISOString()
        items: [{
          id: id
        }]
      auth: oauth2Client
    }, (err, events)->
      if err
        console.log "Googleapis Calendar Events Error:", err
      if callback
        callback err, events

  getCalendarsFromusers: (userList, eventsList, currentUser, callback) ->
    getUsersCalendars userList, eventsList, currentUser, callback

  getAuthClient: (clientId, redirectUri) ->
    return buildAuthClient clientId, redirectUri

# Private Methods
getStoredAuthClient = (user) ->
  clientId = config.googleAuthConfig.clientId
  redirectUri = config.googleAuthConfig.redirectUri
  oauth2Client = googleAuth.getAuthClient clientId, redirectUri
  oauth2Client.setCredentials user.auth
  return oauth2Client

getAuthToken = (authCode, oauth2Client, callback)->
  oauth2Client.getToken authCode, (err, tokens)->
    if err
      console.log "Googleapis Token Error:", err
    if callback
      return callback err, tokens

buildAuthClient = (clientId, redirectUri)->
  secret = config.googleAuthConfig.clientSecret
  OAuth2 = googleapis.auth.OAuth2
  oauth2Client = new OAuth2 clientId, secret, redirectUri
  return oauth2Client

getUsersCalendars = (userList, eventsList, currentUser, callback) ->
  if currentUser >= userList.length
    return callback(eventsList)
  oauth2Client = getStoredAuthClient(userList[currentUser])
  calendar.events.list {
    calendarId: 'primary'
    auth: oauth2Client
  }, (err, events) ->
    if err
      console.log "Googleapis Get Users Calendars Error", err
    eventsList.push(events)
    currentUser++
    return getUsersCalendars userList, eventsList, currentUser, callback

module.exports = googleAuth
