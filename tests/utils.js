'use strict';

process.env.NODE_ENV = 'test';

var db_adapter = require('../dist/database_adapter');
var config = require('config');
var db = db_adapter.getDB();
var user = require('../dist/models/user')


beforeEach(function (done) {
  // Clear contents of Test Database
  db.collections(function(err, collections) {
    for (var i in collections) {
      collections[i].remove(function(){});
    }
    user.insert(
      {
        username: "admin",
        password: user.methods.generateHash("password")
      },
      function(err, result){
        if(err)
          console.log(err);
        return done();
      });
  });
});


after(function (done) {
  //close database connection
  db.close();
  return done();
});

module.exports = db
