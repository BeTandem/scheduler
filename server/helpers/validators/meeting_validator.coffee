config = require 'config'

errorType = "Meeting Validation Error: "

class MeetingValidator
  constructor: (type) ->
    console.log "Created new validator of type", type

  getValidationErrors: (req) ->
    errors = []
    if req.body.meeting_id?
      if not req.body.attendees?
        errors.push errorType + "Required field 'attendees' not provided"

    if errors.length > 0
      return new Error(errors)
    else
      return null

module.exports = MeetingValidator