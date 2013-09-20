'use strict'
logger = require("../logger")
logger.level = "debug"

#TODO: should this be specific to each store??
toAbsoluteUri:(fileName, parentUri, store)->
  #normalization test
  path = require 'path'
  
  segments = fileName.split( "/" )
  if segments[0] != '.' and segments[0] != '..'
    logger.debug("absolute path")
    return fileName
    
  logger.debug("relative path")
  #path is relative
  rootUri = parentUri or store.rootUri or ""
  logger.debug("rootUri", rootUri)
  
  normalized = path.normalize( fileName )
  fullPath = path.resolve( rootUri, fileName )
  fullPath2 = path.join( rootUri, normalized )
  logger.debug("fullPath", fullPath)
  
  return fullPath
  
module.exports = toAbsoluteUri