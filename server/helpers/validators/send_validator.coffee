'use strict'

errorType = "Send Invite Error: "

class SendValidator

  getValidationErrors: (req) ->
    errors = []
    if not req.params.id?
      errors.push errorType + "Required field 'meeting_id' not provided"
    if not req.body.meeting_summary?
      errors.push errorType + "Required field 'meeting_summary' not provided"
    if not req.body.meeting_location?
      errors.push errorType + "Required field 'meeting_location' not provided"
    if not req.body.meeting_time_selection?
      errors.push errorType + "Required field 'meeting_time_selection' not provided"
    if not req.body.meeting_time_selection.start?
      errors.push errorType + "Required field 'meeting_time_selection.start' not provided"
    if not req.body.meeting_time_selection.end?
      errors.push errorType + "Required field 'meeting_time_selection.end' not provided"

    if errors.length > 0
      return new Error(errors)
    else
      return null

module.exports = SendValidator