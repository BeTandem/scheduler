###
@api {get} /meeting/ Meeting create
@apiName CreateMeeting
@apiGroup Meeting

@apiHeader {String} Authorization Bearer auth token.
@apiHeaderExample {json} Header-Example:
{
  "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

@apiSuccess {Boolean} has_prev Whether or not there is a prev token
@apiSuccess {Boolean} has_next Whether or not there is a next token
@apiSuccess {Number} [next] Moment Value of one day after the end of the current week
@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} meeting_id  Id of the Meeting.
@apiSuccess {String} tandem_users  List of Users that are currently in the System.
@apiSuccess {String} schedule  List of all the Available time-slots.

@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
  "has_prev": false,
  "has_next": true,
  "next": 1460959200000,
  "calendar_hours": {
    "morning_start": 8,
    "morning_end": 12,
    "afternoon_start": 12,
    "afternoon_end": 17,
    "evening_start": 17,
    "evening_end": 20
  },
  "meeting_id": "5701bfe987e53e9e06ce5b48",
  "tandem_users": [
    {
      "name": "Test User",
      "email": "test@example.com"
    }
  ],
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

###
@api {get} /meeting/:id Meeting get
@apiName GetMeeting
@apiGroup Meeting

@apiHeader {String} Authorization Bearer auth token.
@apiHeaderExample {json} Header-Example:
{
  "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

@apiParam (Url Param) {String} id Meeting's unique id.

@apiSuccess {Boolean} has_prev Whether or not there is a prev token
@apiSuccess {Boolean} has_next Whether or not there is a next token
@apiSuccess {Number} [next] Moment Value of one day after the end of the current week
@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} meeting_id  Id of the Meeting.
@apiSuccess {String} tandem_users  List of Users that are currently in the System.
@apiSuccess {String} schedule  List of all the Available time-slots.


@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
  "has_prev": false,
  "has_next": true,
  "next": 1460959200000,
  "calendar_hours": {
    "morning_start": 8,
    "morning_end": 12,
    "afternoon_start": 12,
    "afternoon_end": 17,
    "evening_start": 17,
    "evening_end": 20
  },
  "meeting_id": "5701bfe987e53e9e06ce5b48",
  "tandem_users": [
    {
      "name": "Test User",
      "email": "test@example.com"
    }
  ],
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

###
@api {put} /meeting/:id Meeting update
@apiName UpdateMeeting
@apiGroup Meeting

@apiHeader {String} Authorization Bearer auth token.
@apiHeaderExample {json} Header-Example:
{
  "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

@apiParam (Url Param) {String} id Meeting's unique id.
@apiParam (Put Param) {String} [length_in_min] Optional Meeting's unique id.
@apiParam (Put Param) {Object} [details] Optional Meeting Details.
@apiParam (Put Param) {Array} [attendees] Optional List of Meeting Attendee Objects.
@apiParamExample Example Put Object
{
  "attendees": [
    {
      "name": "Test User",
      "email": "xxxxxxx@gmail.com",
      "isTandemUser": true
    }
  ],
  "details": {
    "duration": "30",
    "what": "Event Name",
    "location": "Event Location"
  },
  "length_in_min": "30"
}

@apiSuccess {Boolean} has_prev Whether or not there is a prev token
@apiSuccess {Boolean} has_next Whether or not there is a next token
@apiSuccess {Number} [next] Moment Value of one day after the end of the current week
@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} meeting_id  Id of the Meeting.
@apiSuccess {String} tandem_users  List of Users that are currently in the System.
@apiSuccess {String} schedule  List of all the Available time-slots.

@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
  "has_prev": false,
  "has_next": true,
  "next": 1460959200000,
  "calendar_hours": {
    "morning_start": 8,
    "morning_end": 12,
    "afternoon_start": 12,
    "afternoon_end": 17,
    "evening_start": 17,
    "evening_end": 20
  },
  "meeting_id": "5701bfe987e53e9e06ce5b48",
  "tandem_users": [
    {
      "name": "Test User",
      "email": "test@example.com"
    }
  ],
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

###
@api {post} /meeting/:id Meeting send invite
@apiName SendInvite
@apiGroup Meeting

@apiHeader {String} Authorization Bearer auth token.
@apiHeaderExample {json} Header-Example:
{
  "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

@apiParam (Url Param) {String} id Meeting's unique id.
@apiParam (Post Param) {String} meeting_summary Meeting Description.
@apiParam (Post Param) {String} meeting_location Meeting location.
@apiParam (Post Param) {Array} meeting_time_selection List of Meeting Time Objects.
@apiParam (Post Param) {String} length_in_min Meeting's unique id.
@apiParamExample Example Post Object
{
  "meeting_summary": "Meeting Title",
  "meeting_location": "Meeting Location",
  "meeting_time_selection": {
      "start": "2016-04-06T23:00:00.000Z",
      "end": "2016-04-06T23:30:00.000Z"
  },
  "meeting_length": "30"
}

@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} meeting_id  Id of the Meeting.
@apiSuccess {String} tandem_users  List of Users that are currently in the System.
@apiSuccess {String} schedule  List of all the Available time-slots.

@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
  "kind": "calendar#event",
  "etag": "\"2920696425212000\"",
  "id": "8l3g6mmu7qaia6hh8axxxxxxx",
  "status": "confirmed",
  "htmlLink": "https://www.google.com/calendar/event?eid=OGwzZzZtbXU3cWFpYTZoaDhhZGlkbxxxxxxxxx",
  "created": "2016-04-11T04:16:52.000Z",
  "updated": "2016-04-11T04:16:52.606Z",
  "summary": "Summary Goes Here",
  "description": "<div class=\"container\" style=\"width: 320px; margin-top: 40px; padding: 10px 10px; background-color: #d9d9d9; border-radius: 6px; text-align: center;\">\n<h4 style=\"margin-bottom: 0;\">This meeting was scheduled with</h4>\n<h2 style=\"margin-top: 0; margin-bottom: 30px;\">Tandem Scheduler</h2>\n<p style=\"text-align: center;\">Do you want to schedule meetings in <strong>less than 30</strong> seconds?<br/><br/>\n    <a href=\"https://betandem.com\" target=\"_blank\">Learn More</a> | <a href=\"https://beta.betandem.com\" target=\"_blank\">Try out our beta!</a>\n</p>\n<h6 style=\"margin-top:10px; text-align:center;\">Have feedback to make Tandem better? &nbsp;<a href=\"mailto:tandemscheduler@gmail.com?subject=Tandem Scheduler Feedback\">Send us a messsage</a></h6>\n</div>\n",
  "location": "asdfsdf",
  "creator": {
    "email": "test@example.com",
    "displayName": "Test User",
    "self": true
  },
  "organizer": {
    "email": "test@example.com",
    "displayName": "Test User",
    "self": true
  },
  "start": {
    "dateTime": "2016-04-11T08:45:00-06:00"
  },
  "end": {
    "dateTime": "2016-04-11T09:00:00-06:00"
  },
  "iCalUID": "xxxxxxxxxaia6hh8adidof5ko@google.com",
  "sequence": 0,
  "reminders": {
    "useDefault": true
  }
}
###
