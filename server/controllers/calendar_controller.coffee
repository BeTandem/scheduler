'use strict'

exports = module.exports = (googleAuth, authController, User) ->
  calendarController =

    getCalendarEvents: (req, res) ->
      googleId = req.params.id
      User.findOne {
        id: googleId
      }, (err, user) ->
        if err
          res.status(500).send(err)
        else
          authController.getAuthClient user, (oauth2Client) ->
            googleAuth.getCalendarEventsList oauth2Client, (err, events) ->
              if err
                res.status(500).send(err)
              else
                res.status(200).send(events)

  return calendarController

exports['@require'] = ['helpers/auth/google','controllers/auth_controller', 'models/user']
