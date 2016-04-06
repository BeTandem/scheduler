###
@api {get} /meeting/ Meeting create
@apiName CreateMeeting
@apiGroup Meeting

@apiHeader {String} Authorization Bearer auth token.
@apiHeaderExample {json} Header-Example:
{
  "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} meeting_id  Id of the Meeting.
@apiSuccess {String} tandem_users  List of Users that are currently in the System.
@apiSuccess {String} schedule  List of all the Available time-slots.

@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
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

@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} meeting_id  Id of the Meeting.
@apiSuccess {String} tandem_users  List of Users that are currently in the System.
@apiSuccess {String} schedule  List of all the Available time-slots.


@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
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

@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} meeting_id  Id of the Meeting.
@apiSuccess {String} tandem_users  List of Users that are currently in the System.
@apiSuccess {String} schedule  List of all the Available time-slots.

@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
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
  "meeting_time_selection": [
    {
      "start": "2016-04-06T23:00:00.000Z",
      "end": "2016-04-06T23:30:00.000Z"
    },
    ...
  ],
  "meeting_length": "30"
}

@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} meeting_id  Id of the Meeting.
@apiSuccess {String} tandem_users  List of Users that are currently in the System.
@apiSuccess {String} schedule  List of all the Available time-slots.

@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
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
@api {post} /meeting/:id/attendee Attendee add
@apiName AddAttendee
@apiGroup Meeting/Attendee

@apiHeader {String} Authorization Bearer auth token.
@apiHeaderExample {json} Header-Example:
{
  "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

@apiParam (Url Param) {String} id Meeting's unique id.
@apiParam (Post Param) {string} email User email to add.
@apiParamExample Example Post Object:
{
  "email":"xxxxxxxx@gmail.com"
}

@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} meeting_id  Id of the Meeting.
@apiSuccess {String} tandem_users  List of Users that are currently in the System.
@apiSuccess {String} schedule  List of all the Available time-slots.

@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
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
@api {delete} /meeting/:id/attendee Attendee delete
@apiName DeleteAttendee
@apiGroup Meeting/Attendee

@apiHeader {String} Authorization Bearer auth token.
@apiHeaderExample {json} Header-Example:
{
  "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

@apiParam (Url Param) {String} id Meeting's unique id.
@apiParam (Post Param) {string} email Email address of Atendee to delete.
@apiParamExample Example Post Object:
{
  "email":"xxxxxxxx@gmail.com"
}

@apiSuccess {String} calendar_hours Start and end times of each time block.
@apiSuccess {String} meeting_id  Id of the Meeting.
@apiSuccess {String} tandem_users  List of Users that are currently in the System.
@apiSuccess {String} schedule  List of all the Available time-slots.

@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
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