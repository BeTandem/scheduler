'use strict'

config = require 'config'

errorType = "Login Validation Error: "

class LoginValidator
  constructor: (type) ->
#    console.log "Created new validator of type", type

  getValidationErrors: (req) ->
    errors = []
    if not req.body.code?
      errors.push errorType + "Auth code not provided by login provider"
    if not req.body.clientId?
      errors.push errorType + "Client Id not provided by login provider"
    if not req.body.redirectUri?
      errors.push errorType + "Redirect Uri not provided by login provider"
    if not config.googleAuthConfig.clientSecret?
      errors.push errorType + "Client Secret not set in config file"

    if errors.length > 0
      return new Error(errors)
    else
      return null

module.exports = LoginValidator