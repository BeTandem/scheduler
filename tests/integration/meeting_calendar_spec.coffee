'use strict'

request = require 'supertest'
expect = require('chai').expect
moment = require 'moment'
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


describe '/meeting/:id/calendar/:startDate', ->
  describe 'GET /meeting/:id/calendar/:startDate', ->
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
    googleMock.post(googleMock.FREEBUSY).andRespondFromFile('google_responses/calendar.freebusy.2118.json')
    it 'should return a calendar', (done) ->
      day = 4677458400000
      request(app)
      .get api + '/meeting/56f82142ec6e162822d711d3/calendar/' + day
      .set('Authorization', bearerToken)
      .expect 200
      .end (err, response) ->
        if err
          done(err)
        else
          body = response.body
          expect(body).to.have.property('has_next')
          expect(body).to.have.property('has_prev')
          expect(body).to.have.property('next')
          expect(body).to.have.property('prev')
          expect(body.has_next).to.equal true
          expect(body.has_prev).to.equal true
          expect(body.prev).to.equal moment(day).subtract(1, 'week').valueOf()
          expect(body.next).to.equal moment(day).add(1, 'week').valueOf()
          expect(body).to.have.property('schedule')
          expect(body.schedule).to.have.length NumberOfCalendarDays
          done()