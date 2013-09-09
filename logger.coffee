log = require('logerize') or console.log

logger = {}
logger.level = 'info'
logger.levels = ['error', 'warn', 'info', 'debug'];

formatMessage=(message...)->
  result = []
  for item in message[0]
    if typeof item != 'string'
      item = JSON.stringify(item)
      result.push(item)
    else
      result.push(item)
  result

logger.log = (level, message)->
  levels = ['error', 'warn', 'info', 'debug'];
  if levels.indexOf(level) <= levels.indexOf(logger.level)
    if (typeof message is not 'string')
      message = JSON.stringify(message)
    log(level+': '+message)
      
logger.debug = (message...)->
  message = formatMessage(message)
  message = message.join(" ")
  level = 'debug'
  if logger.levels.indexOf(level) <= logger.levels.indexOf(logger.level)
    log.debug(message)

logger.info = (message...)->
  message = formatMessage(message)
  message = message.join(" ")
  level = "info"
  if logger.levels.indexOf(level) <= logger.levels.indexOf(logger.level)
    log.info(message)

logger.warn = (message...)->
  message = message.join(" ")
  level = "warn"
  if logger.levels.indexOf(level) <= logger.levels.indexOf(logger.level)
    if (typeof message is not 'string')
      message = JSON.stringify(message)
    log.info(message)

logger.error = (message...)->
  message = message.join(" ")
  level = 'error'
  if logger.levels.indexOf(level) <= logger.levels.indexOf(logger.level)
    if (typeof message is not 'string')
      message = JSON.stringify(message)
    log.error(message)

module.exports = logger