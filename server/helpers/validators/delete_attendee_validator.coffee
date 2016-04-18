'use strict'

errorType = "Delete Attendee Validation Error: "

class DeleteAttendeeValidator
  constructor: (type) ->
#    console.log "Created new validator of type", type

  getValidationErrors: (req) ->
    errors = []
    if not req.params.email?
      errors.push errorType + "Required field 'email' not provided"

    if errors.length > 0
      return new Error(errors)
    else
      return null

module.exports = DeleteAttendeeValidator