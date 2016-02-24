jwt         = require 'jsonwebtoken'
googleapis  = require 'googleapis'
User        = require '../models/user'
config      = require 'config'
secrets     = config.get 'secrets'

auth =
  validPassword: (username, password, done)->
    # Password based authentication
    User.find({username: username}).toArray (err, result)->
      if result.length == 1
        userObject = result[0]
        if User.methods.validPassword(password, userObject.password)
          # set up token authentication
          token = createToken(userObject)
          userObject.token = token
          return done null, userObject
      # return same message regardless of login problem
      return done null, false, { message: 'Incorrect login.' }

  google: (req, res) ->
    auth_code = req.body.code
    client_id = req.body.clientId
    redirectUri = req.body.redirectUri
    secret = config.googleAuthConfig.clientSecret

    # Buil Oauth for Google
    OAuth2 = googleapis.auth.OAuth2
    oauth2Client = new OAuth2 client_id, secret, redirectUri
    oauth2Client.getToken auth_code, (err, tokens)->
      if err
        res.status(500).send err
      else
        # Make API request to google for user info
        oauth2Client.setCredentials(tokens)
        oauth2 = googleapis.oauth2('v2')
        oauth2.userinfo.get {
        auth: oauth2Client
        }, (err, google_user) ->
          # Save user & auth information in user object
          google_user.token = createToken(google_user)
          google_user.auth = tokens
          User.methods.findOne { id: google_user.id}, (err, user) ->
            if err
              res.status(500).send err
            else
              if user
                user.token = google_user.token
                response = buildAuthResponse(user)
                res.status(200).send response
              else
                User.methods.addUser google_user, (err, result) ->
                  if err
                    res.status(500).send err
                  else
                    response = buildAuthResponse(google_user)
                    res.status(200).send response

          #TODO: save user info in db with access token

  validToken: (token, done)->
    # verify the token
    verifyToken(token, done)

  authenticate: (req, res, next) ->
    # check if user is authenticated
    if req.isAuthenticated()
      return next()

    # otherwise deny
    res.status(401).send "Unauthorized"

  removeAuthentication: (req, res, next) ->
    # remove session if logged in
    if req.isAuthenticated()
      req.logout()
    return next()


# Private Methods
createToken = (user)->
  return jwt.sign user, secrets.auth, { expiresIn: 7*24*60*60 }

verifyToken = (token, done)->
  # Verify the JWT
  jwt.verify token, secrets.auth, (err, decoded) ->
    if (err)
      return done null, false
    else
      # TODO: Check against session store
      decoded.token = token
      return done null, decoded

buildAuthResponse = (user) ->
  response = {}
  response.id = user._id
  response.token = user.token
  response.email = user.email
  response.name = user.name
  response.picture = user.picture
  return response


module.exports = auth
