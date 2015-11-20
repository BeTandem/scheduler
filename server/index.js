var express     = require('express'),
    bodyParser  = require('body-parser'),
    routes      = require('./routes'),
    http        = require('http');

    var app = express(); // Make app using Express framework
    app.set('port', process.env.PORT || 3000);
    app.set('env', process.env.NODE_ENV || 'development');

    app.use(bodyParser.urlencoded({ extended: false }));
    app.use(bodyParser.json());

    routes(app);

    var server = http.createServer(app);

  server.listen(app.get('port'), function(){
    console.log("Listening on port " + app.get('port') + " in "+ app.get('env') + " mode");
  });

module.exports = app;