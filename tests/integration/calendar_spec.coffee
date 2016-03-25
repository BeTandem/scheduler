app       = require '../../server/index.coffee'
request   = require 'supertest'
expect    = require('chai').expect
Auth      = require '../utils/auth_setup'

# Setup GoogleApis Mock
GoogleMock = require './../utils/google_api_mock'
googleMock = new GoogleMock()

# Setup Mongodb
Database = require '../utils/database_setup'
database = new Database()

api = '/api/v1'
Auth = new Auth()

######################
#CALENDAR ROUTE

describe '/calendar/:calendar_id', ->
  describe 'Get Calendar events with proper Auth', ->
    googleMock.get(googleMock.CAL_EVENTS).andRespondFromFile('test.json')
    database.addUser(database.USER_WITH_AUTH)
    it 'Return JSON from Google', (done)->
      request(app)
        .get(api + '/calendar/111111111111111111111')
        .expect(200)
        .end (err, res) ->
          if err
            console.error err
            done(err)
          else
            expect(res.body.test).to.equal "test"
            done()

  # Unimplemented
#  describe 'Get Calendar events without Auth', ->
#    googleMock.get(googleMock.CAL_EVENTS).andRespondFromFile('test.json')
#    database.addUser(database.USER_NO_AUTH)
#    it 'Return an unauthorized error', (done)->
#      request(app)
#      .get(api + '/calendar/111111111111111111111')
#      .expect(401)
#      .end (err, res) ->
#        if err
#          console.error err
#          done(err)
#        else
#          console.log res.body
#          done()
