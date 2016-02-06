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
  db.collection('rooms')
      .insert {
        name: "Room"
        url: "http://roomcalendar.com/"
      }, (err, result) ->
        if err
          console.log("Could not prepare rooms collection")
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

describe 'Model: Room', ->
  it 'should be able to get rooms', (done)->
    request
    .get('/rooms').use prefix
    .end (err, res) ->
      expect(err).to.equal null
      expect(res.body.length).to.equal 1
      done()

  it 'should be able to get a room by id', (done)->
    db.collection('rooms').find().toArray (err, result)->
      expect(err).to.equal null
      id = result[0]._id
      request
      .get('/rooms/'+id).use prefix
      .end (err, res) ->
        expect(err).to.equal null
        expect(res.body.length).to.equal 1
        expect(res.body[0].name).to.equal 'Room'
        done()

  it 'should be able to add a room', (done)->
    request
    .post('/rooms').use prefix
    .send({name:"Added Room"})
    .end (err, res) ->
      expect(err).to.equal null
      expect(res.body.name).to.equal "Added Room"
      # also check that it is in the test db
      db.collection('rooms').find().toArray (err, result)->
        expect(err).to.equal null
        expect(result.length).to.equal 2
        done()

  it 'should be able to edit a room', (done)->
    db.collection('rooms').find().toArray (err, result)->
      expect(err).to.equal null
      id = result[0]._id
      request.post('/rooms/'+id).use prefix
      .send({name: "Modified Room"})
      .end (err, res) ->
        expect(err).to.equal null
        expect(res.text).to.equal "Successful"
        # also check that it is modified in the test db
        db.collection('rooms').find {_id: mongo.helper.toObjectID(id)}
          .toArray (err, result) ->
            expect(err).to.equal null
            expect(result.length).to.equal 1
            expect(result[0].name).to.equal "Modified Room"
            done()

  it 'should be able to delete a room', (done)->
    db.collection('rooms').find().toArray (err, result) ->
      expect(err).to.equal null
      id = result[0]._id
      request.delete('/rooms/'+id).use prefix
      .end (err, res) ->
        expect(err).to.equal null
        expect(res.text).to.equal "Successful"
        # make sure it was removed from the database
        db.collection('rooms').find().toArray (err, result)->
          expect(err).to.equal null
          expect(result.length).to.equal 0
          done()
