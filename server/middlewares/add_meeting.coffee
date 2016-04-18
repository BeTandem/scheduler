

exports = module.exports = (MeetingModel) ->

  class MeetingMiddleware
    checkAndAddMeetingToRequest: (req, res, next) ->
      # Requires passport to set user first
      user = req.user

      MeetingModel.methods.findById req.params.id, (err, meeting) ->
        if err then return next(err)
        if !meeting
          err = new Error("There is no meeting with the given Id")
          return next(err)
        if meeting.meeting_initiator != user.email
          return res.status(401).send("You are not authorized for the given Id")

        req.meeting = meeting
        next()

  return new MeetingMiddleware()

exports['@require'] = ['models/meeting']