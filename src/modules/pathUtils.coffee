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

parseStoreName: ( uri )->
  isXHr = uri.indexOf("http") isnt -1
  if isXHr 
    return "xhr"
  
  if (uri[0] is "/" ) 
    return "local"
  
  if uri.indexOf(":") isnt -1
    if uri.indexOf(":/") isnt -1 #windows
      return "local"
    return uri.split(":").shift() 
  
  return null#store name not found
  
module.exports.toAbsoluteUri = toAbsoluteUri
module.exports.parseStoreName = parseStoreName