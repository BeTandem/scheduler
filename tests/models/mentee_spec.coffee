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
  db.collection('mentees')
      .insert {
        name: "Mentee"
        url: "http://menteecalendar.com/"
      }, (err, result) ->
        if err
          console.log("Could not prepare mentees collection")
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

describe 'Model: Mentee', ->
  it 'should be able to get mentees', (done)->
    request
    .get('/mentees').use prefix
    .end (err, res) ->
      expect(err).to.equal null
      expect(res.body.length).to.equal 1
      done()

  it 'should be able to get a mentee by id', (done)->
    db.collection('mentees').find().toArray (err, result)->
      expect(err).to.equal null
      id = result[0]._id
      request
      .get('/mentees/'+id).use prefix
      .end (err, res) ->
        expect(err).to.equal null
        expect(res.body.length).to.equal 1
        expect(res.body[0].name).to.equal 'Mentee'
        done()

  it 'should be able to add a mentee', (done)->
    request
    .post('/mentees').use prefix
    .send({name:"Added Mentee"})
    .end (err, res) ->
      expect(err).to.equal null
      expect(res.body.name).to.equal "Added Mentee"
      # also check that it is in the test db
      db.collection('mentees').find().toArray (err, result)->
        expect(err).to.equal null
        expect(result.length).to.equal 2
        done()

  it 'should be able to edit a mentee', (done)->
    db.collection('mentees').find().toArray (err, result)->
      expect(err).to.equal null
      id = result[0]._id
      request.post('/mentees/'+id).use prefix
      .send({name: "Modified Mentee"})
      .end (err, res) ->
        expect(err).to.equal null
        expect(res.text).to.equal "Successful"
        # also check that it is modified in the test db
        db.collection('mentees').find {_id: mongo.helper.toObjectID(id)}
          .toArray (err, result) ->
            expect(err).to.equal null
            expect(result.length).to.equal 1
            expect(result[0].name).to.equal "Modified Mentee"
            done()

  it 'should be able to delete a mentee', (done)->
    db.collection('mentees').find().toArray (err, result) ->
      expect(err).to.equal null
      id = result[0]._id
      request.delete('/mentees/'+id).use prefix
      .end (err, res) ->
        expect(err).to.equal null
        expect(res.text).to.equal "Successful"
        # make sure it was removed from the database
        db.collection('mentees').find().toArray (err, result)->
          expect(err).to.equal null
          expect(result.length).to.equal 0
          done()
