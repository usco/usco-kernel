'use strict'

###*
 *Manager for lifecyle of assets: external stl, amf, textures, fonts etc
*###
class AssetManager
  constructor:( stores )->
  	#manages assets (files)
  	@stores = stores
  	@parsers = {}
  	@assetCache = {}
  	
    
  addParser:( extension, parser )=>
    #add a parser
    @parsers[extension] = new parser()
  
  ###* 
   * Storename : name of the store where to look for filename
   * fileName : path to the file
   * transient : boolean : if true, don't store the resource in cache
   * caching params : various cachin params : lifespan etc
  ###
  loadResource: ( storeName, filename, transient, cachingParams )->
    #load resource, store it in resource map, return it for use
    console.log "resource map", @assetCache
    if not (filename of @assetCache)
      console.log("Resource NOT found")
      extension = filename.split(".").pop()
      
      #console.log "parsers", @parsers, "extension", extension, "store",storeName
      parser = @parsers[ extension ]
      if not parser
        throw new Error("No parser for #{extension}")
      
      store = @stores[ storeName ]
      if not store
        throw new Error("No store named #{store}")
      
      #console.log "store",store, "parser",parser.constructor
      
      rawData = store.loadFile(filename)
      loadedResource = parser.parse(rawData)
    
      @assetCache[filename] = loadedResource
    else
      loadedResource = @assetCache[filename]
      console.log("Resource found")
      
    return loadedResource


  #TODO: this should be the standard, not the version above
  ###* 
   * fileUri : path to the file, starting with the node prefix
   * transient : boolean : if true, don't store the resource in cache
   * caching params : various cachin params : lifespan etc
  ###
  loadResourceByUri: ( fileUri, transient, cachingParams  )->
    #load resource, store it in resource map, return it for use
        
    #extract store:
    storeName = 
    filePath = fileUri.split(":").pop()
    
    if fileUri.indexOf(':') != -1
        storeComponents = includeEntry.split(':')
        store = storeComponents[0]
        filePath = storeComponents[1]
    
    if not (filename of @assetCache)
      console.log("Resource NOT found")
      extension = filename.split(".").pop()
      
      #console.log "parsers", @parsers, "extension", extension, "store",storeName
      parser = @parsers[ extension ]
      if not parser
        throw new Error("No parser for #{extension}")
      
      store = @stores[ storeName ]
      if not store
        throw new Error("No store named #{store}")
      
      #console.log "store",store, "parser",parser.constructor
      
      rawData = store.loadFile(filename)
      loadedResource = parser.parse(rawData)
    
      @assetCache[filename] = loadedResource
    else
      loadedResource = @assetCache[filename]
      console.log("Resource found")
      
    return loadedResource

  unLoadResource: ( store, filename )->
    #todo check references, lifecycle etc
	  
	  
module.exports = AssetManager


