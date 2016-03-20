class ErrorHandler

  handler: (err, res, req, next) ->
    if err
      console.log err
      console.error err.stack
      res.status(400).send({error: err.message})
    else
      next()

module.exports = ErrorHandler