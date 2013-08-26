'use strict'

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
  	
  	#extensions of code file names (do not need parsing)
  	@codeExtensions = ["coffee","litcoffee","ultishape"]
  
      
  _parseFileUri: ( fileUri )->
    #extract store, file path etc
    url = require('url')
    pathInfo = url.parse( fileUri )
    storeName = pathInfo.protocol
    fileName = pathInfo.pathname
    console.log("pathInfo",pathInfo)
    
    if storeName is null
      if pathInfo.path[0] is "/"
        #local fs
        storeName = "local"
        console.log "gne"
      else
        #TODO: deal with relative paths
    
      
    return [ storeName, fileName ] 
    
    
  addParser:( extension, parser )=>
    #add a parser
    @parsers[extension] = new parser()
  
  ###* 
   * fileUri : path to the file, starting with the node prefix
   * transient : boolean : if true, don't store the resource in cache
   * caching params : various cachin params : lifespan etc
   * If no store is specified, file paths are expected to be relative
  ###
  loadResource: ( fileUri, transient, cachingParams  )->
    #load resource, store it in resource map, return it for use
    transient = transient or false    
    
    [storeName,filename] = @_parseFileUri( fileUri )
    console.log("storeName",storeName,"filename",filename)
    #extract store, file path etc
    if fileUri.indexOf(':') != -1
        fileUriElements = fileUri.split(':')
        storeName = fileUriElements[0]
        filename = fileUriElements[1]
    
    if not (filename of @assetCache)
      console.log("Resource NOT found")
      extension = filename.split(".").pop()
      
      #console.log "parsers", @parsers, "extension", extension, "store",storeName
      
      store = @stores[ storeName ]
      if not store
        throw new Error("No store named #{store}")
      
      #console.log "store",store, "parser",parser.constructor
      #load raw data from file
      loadedResource = store.loadFile(filename)
      
      if extension not in @codeExtensions
        parser = @parsers[ extension ]
        if not parser
          throw new Error("No parser for #{extension}")
        loadedResource = parser.parse(loadedResource)
    
      if not transient
        @assetCache[filename] = loadedResource
    else
      loadedResource = @assetCache[filename]
      console.log("Resource found")
      
    return loadedResource

  unLoadResource: ( store, filename )->
    #todo check references, lifecycle etc

	
module.exports = AssetManager


