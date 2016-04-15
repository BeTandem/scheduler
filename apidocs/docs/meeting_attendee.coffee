
###
@api {post} /meeting/:id/attendee/:email Attendee add
@apiName AddAttendee
@apiGroup Meeting/Attendee

@apiHeader {String} Authorization Bearer auth token.
@apiHeaderExample {json} Header-Example:
{
  "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

@apiParam (Url Param) {String} id Meeting's unique id.
@apiParam (Url Param) {String} email User email to add.
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
@api {delete} /meeting/:id/attendee/:email Attendee delete
@apiName DeleteAttendee
@apiGroup Meeting/Attendee

@apiHeader {String} Authorization Bearer auth token.
@apiHeaderExample {json} Header-Example:
{
  "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

@apiParam (Url Param) {String} id Meeting's unique id.
@apiParam (Url Param) {String} email Email address to delete.

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