
'use strict'

exports = module.exports = (_, moment)->

  class CalendarTokenizer

    getCalendarPrevNextTokens: (availability) ->
      [first, ..., last] = availability

      prevNextToken = {
        has_prev: @has_prev(first)
        has_next: @has_next(last)
      }
      if prevNextToken['has_prev']
        prevNextToken['prev'] = @getPrev(first)
      if prevNextToken['has_next']
        prevNextToken['next'] = @getNext(last)

      return prevNextToken

    has_prev: (first) ->
      today = moment().startOf('day')
      firstDay = moment(first.moment).startOf('day')
      return firstDay.diff(today, 'days') > 0

    has_next: () ->
#     For right now, this is always true
      return true

    getPrev: (first) ->
      return moment(first.moment).subtract(1, 'week').startOf('day').valueOf()

    getNext: (last) ->
      return moment(last.moment).add(1, 'day').startOf('day').valueOf()

  return new CalendarTokenizer()


exports['@singleton'] = true
exports['@require'] = ['underscore', 'moment']