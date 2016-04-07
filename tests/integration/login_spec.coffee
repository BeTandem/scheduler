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

logger = require '../../server/helpers/logger'

#######################
#LOGIN ROUTE


describe '/user/login', ->
  returningUserAuth = require '../utils/json/auth/returning_user_auth.json'
  describe 'Post to Login with proper creds', ->
    googleMock.post(googleMock.AUTH).andRespondFromFile('auth/google_authenticated_response.json')
    googleMock.get(googleMock.USER_INFO).andRespondFromFile('google_responses/oauth2.userinfo.with.auth.json')
    it 'should create a new user', (done) ->
      request(app)
      .post api + '/user/login'
      .send returningUserAuth
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

  # Need to implement this functionality
#  describe 'Post to Login without refresh token', ->
#    googleMock.post(googleMock.AUTH).andRespondFromFile('auth/google_authenticated_response.json')
#    googleMock.get(googleMock.USER_INFO).andRespondFromFile('google_responses/oauth2.userinfo.without.auth.json')
#    it 'should return an error', (done) ->
#      request(app)
#      .post api + '/login'
#      .send returningUserAuth
#      .expect 401
#      .end (err, response) ->
#        if err
#          done(err)
#        else
#          done()