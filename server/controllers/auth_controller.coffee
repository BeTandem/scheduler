'use strict'

exports = module.exports = (jwt, config, googleAuth, User) ->

  class AuthController

    constructor: ->
      @secrets = config.get 'secrets'

    googleLogin: (req, res) ->
      authCode = req.body.code
      clientId = req.body.clientId
      redirectUri = req.body.redirectUri

      #Authenticate
      googleAuth.authenticate authCode, clientId, redirectUri, (err, oauth2Client, tokens) =>
        if err
          res.status(500).send err

        #get user Info
        else
          googleAuth.getUserInfo oauth2Client, (err, googleUser) =>
            if err
              res.status(500).send err
            else
              # Build User for database
              googleUser.token = @createToken(googleUser)
              googleUser.auth = tokens
              User.methods.findOne { id: googleUser.id}, (err, user) =>
                if err
                  res.status(500).send err

                if user
                  user.token = googleUser.token
                  response = @buildAuthResponse(user)
                  res.status(200).send response
                else
                  User.methods.addUser googleUser, (err, result) =>
                    if err
                      res.status(500).send err
                    else
                      response = @buildAuthResponse(googleUser)
                      res.status(200).send response

    getAuthClient: (user, callback) ->
      googleAuth.getAuthClient user, (err, oauth2Client) ->
        oauth2Client.setCredentials user.auth
        callback oauth2Client

    validToken: (token, done)->
      # verify the token
      jwt.verify token, @secrets.auth, (err, decoded) ->
        if (err)
          return done err, false
        else
          # TODO: Check against session store
          decoded.token = token
          return done null, decoded

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
    createToken: (user)->
      return jwt.sign user, @secrets.auth, { expiresIn: 7*24*60*60 }

    buildAuthResponse: (user) ->
      response = {}
      response.id = user._id
      response.token = user.token
      response.email = user.email
      response.name = user.name
      response.picture = user.picture
      return response


  return new AuthController()

exports['@require'] = ['jsonwebtoken', 'config', 'helpers/auth/google', 'models/user']