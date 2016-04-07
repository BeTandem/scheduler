'use strict'

db_adapter = require '../../server/database_adapter'
db = db_adapter.getDB()
User = db.collection('user')
Meeting = db.collection('meeting')


class Database
  #Constants
  USER_WITH_AUTH: 'google_authenticated_user.json'
  USER_NO_AUTH: 'google_user_with_no_auth.json'
  MEETING_60: 'meeting.60.minute.json'

  #Methods
  constructor: () ->
    @db = db
    @tasks = []

  addUserTask: (userType) ->
    document = require './json/users/'+ userType
    @tasks.push {
      collection: User,
      document: document,
    }

  addMeetingTask: (meetingType) ->
    document = require './json/meetings/' + meetingType
    @tasks.push {
      collection: Meeting,
      document: document,
    }

  clearDatabase: ->
    before (done) =>
      @db.dropDatabase (err, bla) =>
        if err
          return done(err)
        else
          done()

  runTasks: () ->
    beforeEach (done) =>
      #Clear contents of Test Database
      @db.dropDatabase (err) =>
        if err
          return done(err)
        else
          #Insert a test user
          promiseList = []
          for task in @tasks
            promise = new Promise (resolve, reject) ->
              task.collection.insert task.document, (err) ->
                if err
                  reject(err)
                else
                  resolve()
            promiseList.push(promise)
          Promise.all(promiseList)
          .then (values) =>
            done()
          .catch (err) ->
            done(err)

module.exports = Database
