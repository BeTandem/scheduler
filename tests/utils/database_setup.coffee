'use strict'

exports = module.exports = (db, mongojs) ->
  User = db.collection('user')
  Meeting = db.collection('meeting')


  class Database
    #Constants
    USER_WITH_AUTH: 'google_authenticated_user.json'
    USER_NO_AUTH: 'google_user_with_no_auth.json'
    MEETING_60: 'meeting.60.minute.json'
    MEETING_30: 'meeting.30.minute.json'

    #Methods
    constructor: () ->
      @db = db
      @tasks = []
      @buildTaskList()

    buildTaskList: ->
      @addUserTask(@USER_WITH_AUTH)
      @addUserTask(@USER_NO_AUTH)
      @addMeetingTask(@MEETING_60)
      @addMeetingTask(@MEETING_30)



    addUserTask: (userType) ->
      document = require './json/users/'+ userType
      @tasks.push {
        collection: User,
        document: document,
      }

    addMeetingTask: (meetingType) ->
      document = require './json/meetings/' + meetingType
      document._id = mongojs.ObjectId(document._id)
      @tasks.push {
        collection: Meeting,
        document: document,
      }

    clearDatabase: (callback) ->
      @db.dropDatabase (err) =>
        if err
          return callback(err)
        else
          callback()

    setupDatabase: (done) ->
      #Clear contents of Test Database
      @clearDatabase (err) =>
        if err
          return done(err)
        else
          #Execute Tasks
          promiseList = []
          for task in @tasks
            promise = new Promise (resolve, reject) ->
              task.collection.insert task.document, (err) ->
                if err
                  reject(err)
                else
                  resolve()
            promiseList.push(promise)

          #On Completion of Database Tasks
          Promise.all(promiseList)
          .then =>
            done()
          .catch (err) ->
            done(err)

  return new Database()

exports['@require'] = ['database', 'mongojs']
