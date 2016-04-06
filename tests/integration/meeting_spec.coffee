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
auth = new Auth()
user = require '../utils/json/users/google_authenticated_user.json'
token = auth.createToken(user)

logger = require '../../server/helpers/logger'

#######################
#MEETING ROUTE

describe '/meeting', ->
  describe 'GET /meeting', ->
    googleMock.get(googleMock.TIMEZONE).andRespondFromFile('google_responses/calendar.settings.get.timezone.json')
    googleMock.get(googleMock.CAL_LIST).andRespondFromFile('google_responses/calendar.calendarlist.list.json')
    googleMock.post(googleMock.FREEBUSY).andRespondFromFile('google_responses/calendar.freebusy.json')
    it 'should create a new meeting', (done) ->
      request(app)
      .get api + '/meeting'
      .set('Authorization', "Bearer " + token)
      .expect 200
      .end (err, response) ->
        if err
          done(err)
        else
          body = response.body
          expect(body).to.have.property("meeting_id");
          expect(body).to.have.property("tandem_users");
          expect(body.schedule).to.be.lengthOf(5)
          done()

describe '/meeting/:id', ->
  describe 'GET /meetin/:id', ->
    it 'should retrieve a meeting', (done) ->
      done()
  describe 'PUT /meetin/:id', ->
    it 'should update a meeting', (done) ->
      done()
  describe 'POST /meetin/:id', ->
    it 'should send invites for a meeting', (done) ->
      done()

describe '/meeting/:id/attendee', ->
  describe 'POST /meetin/:id/attendee', ->
    it 'should add an attendee to a meeting', (done) ->
      done()
  describe 'DELETE /meetin/:id/attendee', ->
    it 'should delete an attendee from a meeting', (done) ->
      done()
