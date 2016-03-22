'use strict'

db_adapter = require '../../server/database_adapter'
db = db_adapter.getDB()
User = db.collection('user')


class Database
  #Constants
  USER_WITH_AUTH: 'google_authenticated_user.json'
  USER_NO_AUTH: 'google_user_with_no_auth.json'

  #Methods
  constructor: () ->
    @db = db

  addUser: (userType) ->
    document = require './json/users/'+ userType
    add(User, document)


#Private Methods
add = (collection, document) ->
  beforeEach (done) ->
    #Clear contents of Test Database
    db.dropDatabase (err) ->
      if err
        return done(err)
      else
        #Insert a test user
        collection.insert document, (err) ->
            if err
              return done(err)
            done()

module.exports = Database
