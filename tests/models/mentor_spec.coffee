# Load global before/after

db        = require '../utils'
defaults  = require 'superagent-defaults'
mongo     = require 'mongoskin'
prefix    = require 'superagent-prefix'
chai      = require 'chai'
assert    = chai.assert
expect    = chai.expect
should    = chai.should

prefix = prefix(':3000/api/v1')
request = defaults()

beforeEach (done) ->
  db.collection('mentors')
      .insert {
        name: "Mentor"
      }, (err, result) ->
        if err
          console.log("Could not prepare mentors collection")
        done()

beforeEach (done) ->
  request
    .post('/login').use prefix
    .send({username: 'admin', password: 'password' })
    .end (err, res) ->
      if err
        console.log("Error logging in")
      request
        .set('Authorization', 'Bearer '+res.body.token)
      done()

describe 'Model: Mentor', ->
  it 'should be able to get mentors', (done)->
    request
    .get('/mentors').use prefix
    .end (err, res) ->
      expect(err).to.equal null
      expect(res.body.length).to.equal 1
      done()

  it 'should be able to get a mentor by id', (done)->
    db.collection('mentors').find().toArray (err, result)->
      expect(err).to.equal null
      id = result[0]._id
      request
      .get('/mentors/'+id).use prefix
      .end (err, res) ->
        expect(err).to.equal null
        expect(res.body.length).to.equal 1
        expect(res.body[0].name).to.equal 'Mentor'
        done()

  it 'should be able to add a mentor', (done)->
    request
    .post('/mentors').use prefix
    .send({name:"Added Mentor"})
    .end (err, res) ->
      expect(err).to.equal null
      expect(res.text).to.equal "Successful"
      # also check that it is in the test db
      db.collection('mentors').find().toArray (err, result)->
        expect(err).to.equal null
        expect(result.length).to.equal 2
        done()

  it 'should be able to edit a mentor', (done)->
    db.collection('mentors').find().toArray (err, result)->
      expect(err).to.equal null
      id = result[0]._id
      request.post('/mentors/'+id).use prefix
      .send({name: "Modified Mentor"})
      .end (err, res) ->
        expect(err).to.equal null
        expect(res.text).to.equal "Successful"
        # also check that it is modified in the test db
        db.collection('mentors').find {_id: mongo.helper.toObjectID(id)}
          .toArray (err, result) ->
            expect(err).to.equal null
            expect(result.length).to.equal 1
            expect(result[0].name).to.equal "Modified Mentor"
            done()

  it 'should be able to delete a mentor', (done)->
    db.collection('mentors').find().toArray (err, result) ->
      expect(err).to.equal null
      id = result[0]._id
      request.delete('/mentors/'+id).use prefix
      .end (err, res) ->
        expect(err).to.equal null
        expect(res.text).to.equal "Successful"
        # make sure it was removed from the database
        db.collection('mentors').find().toArray (err, result)->
          expect(err).to.equal null
          expect(result.length).to.equal 0
          done()
