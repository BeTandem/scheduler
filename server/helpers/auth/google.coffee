googleapis  = require 'googleapis'
config      = require 'config'

googleAuth =

  authenticate: (authCode, clientId, redirect_uri, callback) ->
    oauth2Client = getOauth2Client clientId, redirect_uri
    getAuthToken authCode, oauth2Client, (err, tokens) ->
      oauth2Client.setCredentials(tokens)
      if callback
        callback err, oauth2Client, tokens

  getUserInfo: (oauth2Client, callback) ->
    oauth2 = googleapis.oauth2('v2')
    oauth2.userinfo.get {
      auth: oauth2Client
    }, (err, googleUser) ->
      if err
        console.log "Googleapis User Info Error:", err
      if callback
        callback err, googleUser

  getCalendarEventsList: (oauth2Client, callback) ->
    calendar = googleapis.calendar('v3')
    calendar.events.list {
      calendarId: 'primary'
      auth: oauth2Client
    }, (err, events)->
      if err
        console.log "Googleapis Calendar Events Error:", err
      if callback
        callback err, events

# Private Methods
getAuthToken = (authCode, oauth2Client, callback)->
  oauth2Client.getToken authCode, (err, tokens)->
    if err
      console.log "Googleapis Token Error:", err
    if callback
      return callback err, tokens

getOauth2Client = (clientId, redirectUri)->
  secret = config.googleAuthConfig.clientSecret
  OAuth2 = googleapis.auth.OAuth2
  oauth2Client = new OAuth2 clientId, secret, redirectUri
  return oauth2Client


module.exports = googleAuth
