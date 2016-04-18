###
@api {post} /user/login/ Send Login Information for a User
@apiName Login
@apiGroup Authentication

@apiParam (Post Param) {string} code Authentication code from GoogleApis.
@apiParam (Post Param) {string} clientId Client id from front-end application.
@apiParam (Post Param) {string} redirectUri Where to redirect after authentication.
@apiParamExample Example Post Object:
{
  "code": "4/hoGiuFWEIJja8hmLuVS3Bdqn5m4c8XXXXXXXXXXX",
  "clientId": "423949988900-xxxxxx.apps.googleusercontent.com",
  "redirectUri": "http://localhost:8888"
}

@apiSuccess {String} id GoogleId of the User.
@apiSuccess {String} token  Auth token of the User.
@apiSuccess {String} email  Email of the User.
@apiSuccess {String} name  Full name of the User.
@apiSuccess {String} picture  Picture Url for the User.
@apiSuccessExample Successful Response:
HTTP/1.1 200 OK
{
  "id":"5701bbe40e3f58bc0552721a",
  "token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "email":"test@example.com",
  "name":"Test User",
  "picture":"https://lh5.googleusercontent.com/-Hn49LpqLu2I/AAAAAAAAAAI/AAAAAAAAAMw/kWhx1MYUBdk/photo.jpg"
}
###