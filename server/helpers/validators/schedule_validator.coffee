config = require 'config'

errorType = "Schedule Validation Error: "

class ScheduleValidator
  constructor: (type) ->
#    console.log "Created new validator of type", type

  getValidationErrors: (req) ->
    errors = []
    if not req.body.meeting_id?
      errors.push errorType + "Required field 'meeting_id' not provided"
    if not req.body.meeting_summary?
      errors.push errorType + "Required field 'meeting_summary' not provided"
    if not req.body.meeting_location?
      errors.push errorType + "Required field 'meeting_location' not provided"
    if not req.body.meeting_time_selection?
      errors.push errorType + "Required field 'meeting_time_selection' not provided"

    if errors.length > 0
      return new Error(errors)
    else
      return null

module.exports = ScheduleValidator