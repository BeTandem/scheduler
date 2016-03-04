jwt         = require 'jsonwebtoken'
googleAuth  = require '../helpers/auth/google'
User        = require '../models/user'
config      = require 'config'
secrets     = config.get 'secrets'

auth =

  googleLogin: (req, res) ->
    authCode = req.body.code
    clientId = req.body.clientId
    redirectUri = req.body.redirectUri
    secret = config.googleAuthConfig.clientSecret

    #Authenticate
    googleAuth.authenticate authCode, clientId, redirectUri, (err, oauth2Client, tokens) ->
      if err
        res.status(500).send err

      #get user Info
      else
        googleAuth.getUserInfo oauth2Client, (err, googleUser) ->
          if err
            res.status(500).send err
          else
            # Build User for database
            googleUser.token = createToken(googleUser)
            googleUser.auth = tokens
            User.methods.findOne { id: googleUser.id}, (err, user) ->
              if err
                res.status(500).send err

              if user
                user.token = googleUser.token
                response = buildAuthResponse(user)
                res.status(200).send response
              else
                User.methods.addUser googleUser, (err, result) ->
                  if err
                    res.status(500).send err
                  else
                    response = buildAuthResponse(googleUser)
                    res.status(200).send response

  getAuthClient: (user) ->
    clientId = config.googleAuthConfig.clientId
    redirectUri = config.googleAuthConfig.redirectUri
    oauth2Client = googleAuth.getAuthClient clientId, redirectUri
    oauth2Client.setCredentials user.auth
    return oauth2Client

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
