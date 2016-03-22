# TODO: Remove auth var
auth      = require '../../server/helpers/auth/google'

app       = require '../../server/index.coffee'
request   = require 'supertest'
expect    = require('chai').expect

# Setup GoogleApis Mock
GoogleMock = require './../utils/google_api_mock'
googleMock = new GoogleMock()

# Setup Mongodb
Database  = require '../utils/database_setup'
database = new Database()

api = '/api/v1'

#######################
#LOGIN ROUTE

describe '/login', ->
  describe 'Post to Login with proper creds', ->
    it 'should create a new user', (done) ->
      done()

  describe 'Post to Login with improper creds', ->
    it 'should return an error', (done) ->
      done()

  describe 'Post to Login without refresh token', ->
    it 'should return an error', (done) ->
      done()


#######################
#CALENDAR ROUTE

describe '/calendar/:calendar_id', ->
  describe 'Get Calendar events with proper Auth', ->
    googleMock.get(googleMock.CAL_EVENTS).andReplyFromFile('test.json')
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

  describe 'Get Calendar events without Auth', ->
    googleMock.get(googleMock.CAL_EVENTS).andReplyFromFile('test.json')
    database.addUser(database.USER_NO_AUTH)
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
