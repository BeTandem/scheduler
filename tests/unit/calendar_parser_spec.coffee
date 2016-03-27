CalendarParser = require '../../server/helpers/calendar_parser'

moment = require 'moment'
require 'moment-range'
require 'moment-timezone'

logger = require '../../server/helpers/logger'
expect    = require('chai').expect
timezone = "America/Denver"


describe "CalendarParser", ->

  describe "buildEmptyCalendarFormat", ->
    meetingLength = 60
    calendarParser = new CalendarParser(timezone, meetingLength);
    it "should properly build a 5-day empty calendar format", (done) ->
      EmptyCalendarFormat = calendarParser.buildEmptyCalendarFormat();
      expect(EmptyCalendarFormat.length).to.equal 5

      #test values for next day (since current day may not have times)
      tomorrow = EmptyCalendarFormat[1]
      expect(tomorrow.morning.start.toString()).to.equal moment({hour:calendarParser.morningStartHour}).tz(timezone).add(1, 'days').toString()
      expect(tomorrow.afternoon.start.toString()).to.equal moment({hour:calendarParser.afternoonStartHour}).tz(timezone).add(1, 'days').toString()
      expect(tomorrow.evening.start.toString()).to.equal moment({hour:calendarParser.eveningStartHour}).tz(timezone).add(1, 'days').toString()

      #all ending times should be less than meeting time by the meeting length
      expect(tomorrow.morning.end.toString()).to.equal moment({hour:calendarParser.afternoonStartHour}).tz(timezone).add(1, 'days').subtract(meetingLength, "minutes").toString()
      expect(tomorrow.afternoon.end.toString()).to.equal moment({hour:calendarParser.eveningStartHour}).tz(timezone).add(1, 'days').subtract(meetingLength, "minutes").toString()
      expect(tomorrow.evening.end.toString()).to.equal moment({hour:calendarParser.dayEndHour}).tz(timezone).add(1, 'days').subtract(meetingLength, "minutes").toString()

      done()

  describe "buildMeetingCalendar", ->

    it "should build the correct number of availble slots wit no busy", (done) ->
      meetingLength = 60
      calendarParser = new CalendarParser(timezone, meetingLength);
      calendarAvailability = calendarParser.buildMeetingCalendar([]);
      expect(calendarAvailability.length).to.equal 5
      expect(calendarAvailability[1].morning.length).to.equal 13
      expect(calendarAvailability[1].afternoon.length).to.equal 17
      expect(calendarAvailability[1].evening.length).to.equal 9
      done()

    it "should create more availability slots with meeting length of 15 minutes", (done) ->
      meetingLength = 15
      calendarParser = new CalendarParser(timezone, meetingLength);
      calendarAvailability = calendarParser.buildMeetingCalendar([]);
      expect(calendarAvailability.length).to.equal 5
      expect(calendarAvailability[1].morning.length).to.equal 16
      expect(calendarAvailability[1].afternoon.length).to.equal 20
      expect(calendarAvailability[1].evening.length).to.equal 12
      done()

    it "should have no availability for morning, afternoon, and evening on their respective days", (done) ->
      meetingLength = 60
      calendarParser = new CalendarParser(timezone, meetingLength);
      freeBusyCal = {
        kind: "calendar#freeBusy"
        timeMin: "this_field_doesnt_matter"
        timeMax: "this_field_doesnt_matter"
        calendars: {
          "xxxxx@gmail.com": {
            busy: [
              {
                start: moment({hour:calendarParser.morningStartHour}).add(1, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
                end: moment({hour:calendarParser.afternoonStartHour}).add(1, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
              }
              {
                start: moment({hour:calendarParser.afternoonStartHour}).add(2, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
                end: moment({hour:calendarParser.eveningStartHour}).add(2, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
              }
              {
                start: moment({hour:calendarParser.eveningStartHour}).add(3, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
                end: moment({hour:calendarParser.dayEndHour}).add(3, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
              }
            ]
          }
        }
      }
      calendarAvailability = calendarParser.buildMeetingCalendar([freeBusyCal])
      expect(calendarAvailability[1].morning.length).to.equal 0
      expect(calendarAvailability[1].afternoon.length).to.equal 17
      expect(calendarAvailability[1].evening.length).to.equal 9

      expect(calendarAvailability[2].morning.length).to.equal 13
      expect(calendarAvailability[2].afternoon.length).to.equal 0
      expect(calendarAvailability[2].evening.length).to.equal 9

      expect(calendarAvailability[3].morning.length).to.equal 13
      expect(calendarAvailability[3].afternoon.length).to.equal 17
      expect(calendarAvailability[3].evening.length).to.equal 0
      done()

    it "should have correct availability when only part of the time is availabile", (done) ->
      meetingLength = 60
      calendarParser = new CalendarParser(timezone);
      freeBusyCal = {
        kind: "calendar#freeBusy"
        timeMin: "this_field_doesnt_matter"
        timeMax: "this_field_doesnt_matter"
        calendars: {
          "xxxxx@gmail.com": {
            busy: [
              {
                start: moment({hour:calendarParser.morningStartHour}).add(1, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
                end: moment({hour:calendarParser.afternoonStartHour-2}).add(1, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
              }
              {
                start: moment({hour:calendarParser.afternoonStartHour+2}).add(2, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
                end: moment({hour:calendarParser.eveningStartHour}).add(2, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
              }
              {
                start: moment({hour:calendarParser.eveningStartHour}).add(3, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
                end: moment({hour:calendarParser.dayEndHour-1}).add(3, 'days').tz("UTC").format("YYYY-MM-DDTHH:mm:ss")+"Z"
              }
            ]
          }
        }
      }
      calendarAvailability = calendarParser.buildMeetingCalendar([freeBusyCal])
      expect(calendarAvailability[1].morning.length).to.equal 5
      expect(calendarAvailability[1].afternoon.length).to.equal 17
      expect(calendarAvailability[1].evening.length).to.equal 9

      expect(calendarAvailability[2].morning.length).to.equal 13
      expect(calendarAvailability[2].afternoon.length).to.equal 5
      expect(calendarAvailability[2].evening.length).to.equal 9

      expect(calendarAvailability[3].morning.length).to.equal 13
      expect(calendarAvailability[3].afternoon.length).to.equal 17
      expect(calendarAvailability[3].evening.length).to.equal 1
      done()