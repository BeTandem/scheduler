logger = require './logger'

class ErrorHandler

  handler: (err, req, res, next) ->
    if err
      logger.error err.message, err.stack
      res.status(400).send({error: err.message})
    else
      next()

module.exports = ErrorHandler