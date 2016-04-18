'use strict'

exports = module.exports = (winston, moment)->
  SERVER_LOG = if process.env.NODE_ENV == 'test' then 'logs/test.log' else 'logs/server.log'
  EXCEPTIONS_LOG = if process.env.NODE_ENV == 'test' then 'logs/test.log' else 'logs/exceptions.log'

  logger = new winston.Logger {
    levels:
      server: 0
      debug: 1
      error: 2
      info: 3

    colors:
      SERVER: 'green'
      DEBUG: 'magenta'
      ERROR: 'red'
      INFO: 'blue'

    transports: [
  # Only display debug statements in console
      new winston.transports.Console {
        prettyPrint: true
        colorize: true
        level: 'debug' #debug and lower levels
        silent: false
        formatter: (options) ->
          message = if undefined != options.message then options.message else ''
          meta = if (options.meta && Object.keys(options.meta).length) then ('\n\t' + JSON.stringify(options.meta)) else ''
          return winston.config.colorize(options.level.toUpperCase()) + ': ' + message + meta
      }
  # Write all logger statements log file
      new winston.transports.File {
        filename: SERVER_LOG
        json: false
        prettyPrint: true
        timestamp: ->
          moment().format()
        formatter: (options) ->
          timestamp = options.timestamp()
          level = options.level.toUpperCase()
          message = if undefined != options.message then options.message else ''
          meta = if (options.meta && Object.keys(options.meta).length) then ('\n\t' + JSON.stringify(options.meta)) else ''
          return '[' + timestamp + '] ' + level + ': ' + message + meta
      }
    ]
    exceptionHandlers: [
      new winston.transports.File {
        filename: EXCEPTIONS_LOG
        json: false
        prettyPrint: true
      }
    ]
  }

  return logger

exports['@singleton'] = true
exports['@require'] = ['winston', 'moment']