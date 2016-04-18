'use strict'

applicationBuilder = require '../utils/test_server_factory'
moment = require 'moment'
require 'moment-range'
require 'moment-timezone'

expect    = require('chai').expect
timezone = "America/Denver"

describe "CalendarTokenizer", ->
  ioc = {}
  beforeEach ->
    ioc = applicationBuilder.getDefaultIoc()

  describe "getCalendarPrevNextTokens", ->
    it "should should only build a next token for this week", (done) ->
      CalendarParser = new (ioc.create('helpers/calendar_parser'))()
      availability = CalendarParser.buildEmptyCalendarFormat(moment())

      CalendarTokenizer = ioc.create 'helpers/calendar_tokenizer'
      prevNextTokens = CalendarTokenizer.getCalendarPrevNextTokens(availability)

      expect(prevNextTokens).to.have.property('has_prev')
      expect(prevNextTokens).to.have.property('has_next')
      expect(prevNextTokens).to.have.property('next')
      expect(prevNextTokens).to.not.have.property('prev')
      expect(prevNextTokens.has_prev).to.equal false
      expect(prevNextTokens.has_next).to.equal true

      done()

    it "should should both prev and next token for this week", (done) ->
      CalendarParser = new (ioc.create('helpers/calendar_parser'))()
      availability = CalendarParser.buildEmptyCalendarFormat(moment().add(1,'week'))

      CalendarTokenizer = ioc.create 'helpers/calendar_tokenizer'
      prevNextTokens = CalendarTokenizer.getCalendarPrevNextTokens(availability)

      expect(prevNextTokens).to.have.property('has_prev')
      expect(prevNextTokens).to.have.property('has_next')
      expect(prevNextTokens).to.have.property('next')
      expect(prevNextTokens).to.have.property('prev')
      expect(prevNextTokens.has_prev).to.equal true
      expect(prevNextTokens.has_next).to.equal true

      done()