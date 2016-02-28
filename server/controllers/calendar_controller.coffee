googleAuth  = require '../helpers/auth/google'
User        = require '../models/user'
authController = require './auth_controller'

calendarController =

  getCalendarEvents: (req, res) ->
    googleId = req.params.id
    User.findOne {
      id: googleId
    }, (err, user) ->
      if err
        res.status(500).send(err)
      else
        oauth2Client = authController.getAuthClient(user)
        googleAuth.getCalendarEventsList oauth2Client, (err, events) ->
          if err
            res.status(500).send(err)
          else
            res.status(200).send(events)


module.exports = calendarController
