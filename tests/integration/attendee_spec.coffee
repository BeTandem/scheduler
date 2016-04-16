'use strict'

request = require 'supertest'
expect = require('chai').expect
Auth = require '../utils/auth_setup'
applicationBuilder = require '../utils/test_server_factory'


# Setup GoogleApis Mock
GoogleMock = require './../utils/google_api_mock'
googleMock = new GoogleMock()

api = '/api/v1'
auth = new Auth()
user = require '../utils/json/users/google_authenticated_user.json'
bearerToken = "Bearer " + auth.createToken(user)

NumberOfCalendarDays = 7

#######################
#MEETING ROUTE

describe '/meeting/:id/attendee/:email', ->
  describe 'POST /meeting/:id/attendee/:email', ->
    app = {}
    server = {}
    before (done) ->
      ioc = applicationBuilder.getDefaultIoc()
      appBuilder = applicationBuilder.provide(ioc)
      {app: app, server: server} = appBuilder
      ioc.create('database_setup').setupDatabase(done)
    after (done) ->
      server.close(done)
    googleMock.get(googleMock.TIMEZONE).andRespondFromFile('google_responses/calendar.settings.get.timezone.json')
    googleMock.get(googleMock.CAL_LIST).andRespondFromFile('google_responses/calendar.calendarlist.list.json')
    googleMock.post(googleMock.FREEBUSY).andRespondFromFile('google_responses/calendar.freebusy.json')
    it 'should add an attendee', (done) ->
      request(app)
      .post api + '/meeting/56f82142ec6e162822d711d3/attendee/added-email@gmail.com'
      .set('Authorization', bearerToken)
      .send {
        "email":"added-email@gmail.com"
      }
      .expect 200
      .end (err, response) ->
        if err
          done(err)
        else
          body = response.body
          expect(body).to.have.property("tandem_users");
          expect(body.schedule).to.be.lengthOf(NumberOfCalendarDays)
          Meeting = app.ioc.create('models/meeting')

          Meeting.methods.findById "56f82142ec6e162822d711d3", (err, meeting) ->
            if err then return done(err)
            expect(meeting).to.have.property "emails"
            expect(meeting.emails.length).to.equal 1
            expect(meeting.emails).to.have.length 1
            expect(meeting.emails[0]).to.equal "added-email@gmail.com"
            done()

  describe 'DELETE /meeting/:id/attendee/:email', ->
    app = {}
    server = {}
    before (done) ->
      ioc = applicationBuilder.getDefaultIoc()
      appBuilder = applicationBuilder.provide(ioc)
      {app: app, server: server} = appBuilder
      ioc.create('database_setup').setupDatabase(done)
    after (done) ->
      server.close(done)
    googleMock.get(googleMock.TIMEZONE).andRespondFromFile('google_responses/calendar.settings.get.timezone.json')
    googleMock.get(googleMock.CAL_LIST).andRespondFromFile('google_responses/calendar.calendarlist.list.json')
    googleMock.post(googleMock.FREEBUSY).andRespondFromFile('google_responses/calendar.freebusy.json')
    it 'should remove an attendee', (done) ->
      request(app)
      .delete api + '/meeting/570af3bc8759a10a72cdd069/attendee/example@example.com'
      .set('Authorization', bearerToken)
      .expect 200
      .end (err, response) ->
        if err
          done(err)
        else
          body = response.body
          expect(body).to.have.property("tandem_users");
          expect(body.schedule).to.be.lengthOf(NumberOfCalendarDays)
          Meeting = app.ioc.create('models/meeting')

          Meeting.methods.findById "570af3bc8759a10a72cdd069", (err, meeting) ->
            if err then return done(err)
            expect(meeting).to.have.property "emails"
            expect(meeting.emails).to.have.length 0
            done()
