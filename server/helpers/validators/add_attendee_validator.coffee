errorType = "Add Attendee Validation Error: "

class AddAttendeeValidator
  constructor: (type) ->
    console.log "Created new validator of type", type

  getValidationErrors: (req) ->
    errors = []
    if not req.body.meeting_id?
      errors.push errorType + "Required field 'meeting_id' not provided"
    if not req.body.email?
      errors.push errorType + "Required field 'email' not provided"

    if errors.length > 0
      return new Error(errors)
    else
      return null

module.exports = AddAttendeeValidator