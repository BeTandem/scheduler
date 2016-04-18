'use strict'

request = require 'supertest'
expect = require('chai').expect
applicationBuilder = require '../utils/test_server_factory'

# Setup GoogleApis Mock
GoogleMock = require '../utils/google_api_mock'
googleMock = new GoogleMock()

Auth = require '../utils/auth_setup'
auth = new Auth()

api = '/api/v1'

describe '/user/login', ->
  authFromFrontend = require '../utils/json/auth/returning_user_auth.json'
  app = {}
  server = {}
  beforeEach ->
    ioc = applicationBuilder.getDefaultIoc()
    appBuilder = applicationBuilder.provide(ioc)
    {app: app, server: server} = appBuilder
  afterEach (done) ->
    server.close(done)
  describe 'Post to Login with proper creds', ->
    before ->
      googleMock.post(googleMock.AUTH).andRespondFromFile('auth/google_authenticated_response.json')
      googleMock.get(googleMock.USER_INFO).andRespondFromFile('google_responses/oauth2.userinfo.with.auth.json')
    it 'should create a new user', (done) ->
      request(app)
      .post api + '/user/login'
      .send authFromFrontend
      .expect 200
      .end (err, response) ->
        if err
          done(err)
        else
          body = response.body
          expect(body).to.have.property('id')
          expect(body).to.have.property('token')
          expect(body.name).to.equal('Test User')
          expect(body.email).to.equal('test@example.com')
          auth.verifyToken body.token, (err, decoded) ->
            # Same email address should be in the decoded token
            expect(decoded.email).to.equal('test@example.com')
            done()

  describe 'Post to Login with improper creds', ->
    it 'should return an 400 Bad request error', (done) ->
      request(app)
      .post api + '/user/login'
      .expect 400
      .end (err, response) ->
        if err
          done(err)
        else
          expect(response.body).to.have.property('error')
          done()

# Need to implement this functionality (Issue #50)
#  describe 'Post to Login and google returns without refresh token', ->
#    authFromFrontend = require '../utils/json/auth/returning_user_auth.json'
#    before ->
#      googleMock.post(googleMock.AUTH).andRespondFromFile('auth/google_authenticated_response.json')
#      googleMock.get(googleMock.USER_INFO).andRespondFromFile('google_responses/oauth2.userinfo.without.auth.json')
#    it 'should return an error', (done) ->
#      request(app)
#      .post api + '/user/login'
#      .send authFromFrontend
#      .expect 400
#      .end (err, response) ->
#        if err
#          done(err)
#        else
#          done()