'use strict'

LoginValidator = require './validators/login_validator'
AddAttendeeValidator = require './validators/add_attendee_validator'
DeleteAttendeeValidator = require './validators/delete_attendee_validator'
MeetingValidator = require './validators/meeting_validator'
ScheduleValidator = require './validators/schedule_validator'

class Validator
  validateType: (type) ->
    switch type
      when "login" then new LoginValidator(type)
      when "add_attendee" then new AddAttendeeValidator(type)
      when "delete_attendee" then new DeleteAttendeeValidator(type)
      when "meeting" then new MeetingValidator(type)
      when "schedule" then new ScheduleValidator(type)

exports = module.exports = ->
  return new Validator()

