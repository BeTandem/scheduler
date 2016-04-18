
###
@api {post} /meeting/:id/calendar/:startDate Get Calendar
@apiName GetCalendar
@apiGroup Meeting/Calendar

@apiHeader {String} Authorization Bearer auth token.
@apiHeaderExample {json} Header-Example:
{
  "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

@apiParam (Url Param) {String} id Meeting's unique id.
@apiParam (Url Param) {Number} startDate Date number representing start of request week. Ex: '1460959200000'

@apiSuccess {Boolean} has_prev Whether or not there is a prev token
@apiSuccess {Boolean} has_next Whether or not there is a next token
@apiSuccess {Number} [next] Moment Value of one day after the end of the current week
@apiSuccess {Number} [prev] Moment Value of one week before the beginning of the current week
@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} schedule  List of all the Available time-slots.

@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
  "has_prev": true,
  "has_next": true,
  "next": 1460959200000,
  "next": 1460959200000,
  "calendar_hours": {
    "morning_start": 8,
    "morning_end": 12,
    "afternoon_start": 12,
    "afternoon_end": 17,
    "evening_start": 17,
    "evening_end": 20
  },
  "schedule": [
    {
      "day_code": "Sun, Apr 3rd",
      "morning": [
        {
          "start": "2016-04-04T14:45:00.000Z",
          "end": "2016-04-04T15:45:00.000Z"
        }
      ],
      "afternoon": [],
      "evening": []
    },
    ...
  ]
}
###