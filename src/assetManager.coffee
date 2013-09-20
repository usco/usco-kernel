'use strict'
path = require('path')
Q = require("q")
logger = require("../logger")
logger.level = "info"

#TODO: add loading from git repos , with optional tag, commit, hash, branch etc (similar to npm dependencies)
#TODO: perhaps we should seperate store TYPE (local , xhr, dropbox) from store NAME (the root uri ?)

###*
 *Manager for lifecyle of assets: load, store unload 
 *For external code files, stl, amf, textures, fonts etc
*###
class AssetManager
  constructor:( stores )->
  	#manages assets (files)
  	@stores = stores
  	@parsers = {}
  	@assetCache = {}
  	
  	#extensions of code file names (do not need parsing, but more complex evaluating !!)
  	@codeExtensions = ["coffee","litcoffee","ultishape","scad"]
  
  _parseStoreName: ( uri )->
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
  	
  _parseFileUri: ( fileUri )->
    #extract store, file path etc
    #logger.debug "extracting store from", fileUri
    url = require('url')
    pathInfo = url.parse( fileUri )
    storeName = pathInfo.protocol
    fileName = pathInfo.host  + pathInfo.pathname
    storeName = storeName.replace(":","")
    
    if storeName is null
      if pathInfo.path[0] is "/"
        #local fs
        storeName = "local"
      else
        #TODO: deal with relative paths
    else if storeName is "http" or storeName is "https"
      storeName = "xhr"
      fileName = pathInfo.href
    
    return [ storeName, fileName ] 
  
  _toAbsoluteUri:(fileName, parentUri, store)->
    #normalization test
    path = require 'path'
    
    segments = fileName.split( "/" )
    if segments[0] != '.' and segments[0] != '..'
      logger.debug("fullPath (from absolute)", fileName)
      return fileName
    
    #logger.debug("relative path: ", fileName)
    #path is relative
    rootUri = parentUri or store.rootUri or ""
    fileName = path.normalize(fileName)
    isXHr = rootUri.indexOf("http") isnt -1
    
    #TODO: this explains WHY it would be a good idea to have path resolving done on a PER STORE basis
    if isXHr
      fullPath = rootUri + fileName
    else
      #hack to force dirname to work on paths ending with slash
      rootUri = if rootUri[rootUri.length-1] == "/" then rootUri +="a" else rootUri
      rootUri = path.normalize(rootUri)
      rootUri = path.dirname(rootUri)
      fullPath = path.join( rootUri, fileName )
      
      
    logger.debug("fullPath (from relative)", fullPath)
    
    return fullPath
  
  addParser:( extension, parser )=>
    #add a parser
    @parsers[extension] = new parser()
  
  ###* 
   * fileUri : path to the file, starting with the node prefix
   * transient : boolean : if true, don't store the resource in cache
   * parentUri : string : not sure we should have this here : for relative path resolution
   * caching params : various cachin params : lifespan etc
   * If no store is specified, file paths are expected to be relative
  ###
  loadResource: ( fileUri, parentUri, cachingParams  )->
    #load resource, store it in resource map, return it for use
    parentUri = parentUri or null
    
    transient = if cachingParams? then cachingParams.transient else false    
    
    deferred = Q.defer()
    
    if not fileUri?
      throw new Error( "Invalid file name : #{fileUri}" )
     
    #resolve full path
    fileUri = @_toAbsoluteUri(fileUri, parentUri)
    
    [storeName,filename] = @_parseFileUri( fileUri, parentUri)
    logger.info( "Attempting to load :", filename,  "from store:", storeName )
    
    #get store instance , if it exists
    store = @stores[ storeName ]
    if not store
      throw new Error("No store named #{storeName}")
    
    if not (filename of @assetCache)
      extension = filename.split(".").pop()
      #load raw data from file, get a deferred
      loaderDeferred = store.loadFile(filename)
      
      #loadedResource 
      loaderDeferred
      .then (loadedResource) =>
        if extension not in @codeExtensions
          parser = @parsers[ extension ]
          if not parser
            throw new Error("No parser for #{extension}")
          loadedResource = parser.parse(loadedResource)
        #if we are meant to hold on to this resource, cache it
        if not transient
          @assetCache[ fileUri ] = loadedResource
          
        #and return it
        #deferred.resolve( loadedResource )  
        #TODO: alternative: can be practical so we can use the deferred directly : [fileUri, loadedResource]
        deferred.resolve([fileUri, loadedResource])  
        
       .fail (error) =>
         #TODO: alternative: can be practical so we can use the deferred directly : [fileUri, loadedResource]
         deferred.reject( [fileUri, error] )
    else
      #the resource was already loaded, return it 
      loadedResource = @assetCache[filename]
      deferred.resolve( loadedResource )
      
    return deferred.promise

  ###*** 
  *remove resource from cached assets
  ###
  unLoadResource: ( fileUri )->
    #TODO : should resources be wrapped so we can deal with MANUAL reference counting, metadata etc?
    if (fileUri of @assetCache)
      delete @assetCache[ fileUri ]
      
  ###***
  *load project (folder): TODO: should this be here ??
  * @param {string} uri: folder/url path
  ###
  loadProject:( uri )->
    deferred = Q.defer()
    storeName = @_parseStoreName( uri )
    console.log "storeName", storeName
    
    return deferred.promise
  
	
module.exports = AssetManager

