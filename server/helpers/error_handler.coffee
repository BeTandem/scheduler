class ErrorHandler

  handler: (err, req, res, next) ->
    if err
#      console.error err.stack
      res.status(400).send({error: err.message})
    else
      next()

module.exports = ErrorHandler