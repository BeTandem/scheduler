jwt  = require 'jsonwebtoken'
User = require '../models/user'


auth =
  validPassword: (username, password, done)->
    # Password based authentication
    User.find({username: username}).toArray (err, result)->
      console.log("VALIDATING PASSWORD")
      if result.length == 1
        userObject = result[0]
        if User.methods.validPassword(password, userObject.password)
          # set up token authentication
          token = createToken(userObject)
          userObject.token = token
          return done null, userObject
      # return same message regardless of login problem
      return done null, false, { message: 'Incorrect login.' }

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
  # remove hashed pass from returned object
  delete user.password
  # TODO: move to ENV
  return jwt.sign user, 'supersecret', { expiresIn: 7*24*60*60 }

verifyToken = (token, done)->
  # Verify the JWT
  # TODO: move to ENV
  jwt.verify token, 'supersecret', (err, decoded) ->
    if (err)
      return done null, false
    else
      # TODO: Check against session store
      decoded.token = token
      return done null, decoded

module.exports = auth
