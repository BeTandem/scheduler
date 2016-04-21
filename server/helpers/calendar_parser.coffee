'use strict'

exports = module.exports = (_, moment)->

  calendarDays = 7

# load dependencies for moment
  require 'moment-range'
  require 'moment-timezone'

  class CalendarParser
    #constants
    morningStartHour: 8
    afternoonStartHour: 12
    eveningStartHour: 17
    dayEndHour: 20
    meetingLengthDefault: 60


    constructor: (timezone, meetingLengthInMinutes) ->
      @timezone = timezone
      @meetingLengthInMinutes = meetingLengthInMinutes || @meetingLengthDefault

    buildMeetingCalendar: (calendarsList, startDayTime) ->
      meetDuration = moment.duration(minutes: @meetingLengthInMinutes)
      flattenedCalendar = @flattenCalendars(calendarsList)
      busyMomentRanges = @convertFreeBusyToMomentRanges(flattenedCalendar)
      emptyCalendar = @buildEmptyCalendarFormat(startDayTime)

      #Build Out fifteen min range for iteration
      now = moment()
      fifteenMinutes = moment.duration(15, 'minutes')
      fifteenMinRange = moment.range(now, moment(now).add(fifteenMinutes))

      availableRanges = []
      for day in emptyCalendar
        dayObj =
          day_code: day.day_code
          moment: day.moment
        delete day['moment']
        delete day['day_code']

        for key, timeRange of day
          dayObj[key] = []
          if timeRange
            timeRange.by fifteenMinRange, (time) =>
              newRange = moment.range(time, moment(time).add(meetDuration))
              if @isTimeRangeAvailable(newRange, busyMomentRanges)
                dayObj[key].push(newRange)

        availableRanges.push(dayObj)
      return availableRanges


    flattenCalendars: (cals) ->
      relCals = []
      freeBusy = []
      for calObject in cals
        for name, calendar of calObject.calendars
          relCals.push calendar
      for times in relCals
        freeBusy.push times.busy
      return _.flatten freeBusy


    convertFreeBusyToMomentRanges: (flattenedCalendar) ->
      freeBusyRanges = []
      for busy in flattenedCalendar
        range = moment.range(moment.utc(busy.start), moment.utc(busy.end))
        freeBusyRanges.push(range)
      return freeBusyRanges

    isTimeRangeAvailable: (range, freeBusyRanges) ->
      for busy in freeBusyRanges
        if range.overlaps(busy)
          return false
      return true

    buildEmptyCalendarFormat: (startDayTime) ->
      calendarChunks = []
      # Get Range
      nowTime = moment()
      startDayMoment = moment(startDayTime)
      endDayMoment = moment(startDayMoment).add(moment.duration(calendarDays-1, 'days'))
      week = moment.range(startDayMoment, endDayMoment)

      #iterate through days to create time chunks
      week.by 'days', (day) =>
        dayObj =
          moment: day
          day_code: day.format('ddd, MMM Do') #Example: 'Tue, Mar 15th'
          morning: null
          afternoon: null
          evening: null
        utcTimes = @getUTCTimesFromTimezone(day)

        #create morning Range

        morning = moment.range(utcTimes.mornStart, utcTimes.mornEnd)
        if nowTime.unix() < utcTimes.mornStart.unix()
          dayObj.morning = morning

        #create afternoon Range
        afternoon = moment.range(utcTimes.aftStart, utcTimes.aftEnd)
        if nowTime.unix() < utcTimes.aftStart.unix()
          dayObj.afternoon = afternoon

        #create evening Range
        evening = moment.range(utcTimes.evStart, utcTimes.evEnd)
        if nowTime.unix() < utcTimes.evStart.unix()
          dayObj.evening = evening

        calendarChunks.push dayObj

      return calendarChunks


    getUTCTimesFromTimezone: (day) ->
      time =
        year: day.year()
        month: day.month()
        day: day.date()

      utcTimes = {}
      time.hour = @morningStartHour
      utcTimes.mornStart = moment.tz(time, @timezone)
      time.hour = @afternoonStartHour
      utcTimes.aftStart = moment.tz(time, @timezone)
      utcTimes.mornEnd = moment(utcTimes.aftStart).subtract(@meetingLengthInMinutes, "minutes")
      time.hour = @eveningStartHour
      utcTimes.evStart = moment.tz(time, @timezone)
      utcTimes.aftEnd = moment(utcTimes.evStart).subtract(@meetingLengthInMinutes, "minutes")
      time.hour = @dayEndHour
      utcTimes.evEnd = moment.tz(time, @timezone).subtract(@meetingLengthInMinutes, "minutes")

      return utcTimes

  return CalendarParser

exports['@require'] = ['underscore', 'moment']