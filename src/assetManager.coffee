'use strict'
Q = require("q")

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
  	
  	#for relative paths: needs full uri (store included)
  	#TODO: maybe this is not needed, full paths should be resolved else
  	#where BEFORE asking the asset manager to load anything
  	@currentLocation = ""
      
  _parseFileUri: ( fileUri )->
    #extract store, file path etc
    #console.log "extracting store from", fileUri
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
    
    deferred = Q.defer()
    
    [storeName,filename] = @_parseFileUri( fileUri )
    console.log("storeName",storeName,"filename",filename)
    
    if not (filename of @assetCache)
      extension = filename.split(".").pop()
      #console.log "parsers", @parsers, "extension", extension, "store",storeName
      
      store = @stores[ storeName ]
      if not store
        throw new Error("No store named #{storeName}")
      
      #load raw data from file, get a deferred
      loaderDeferred = store.loadFile(filename)
      
      #loadedResource 
      loaderDeferred.then (loadedResource) =>
        if extension not in @codeExtensions
          parser = @parsers[ extension ]
          if not parser
            throw new Error("No parser for #{extension}")
          loadedResource = parser.parse(loadedResource)
        #if we are meant to hold on to this resource, cache it
        if not transient
          @assetCache[ fileUri ] = loadedResource
          
        #and return it
        deferred.resolve( loadedResource )  
       .fail (error) =>
         deferred.reject( error )
    else
      #the resource was already loaded, return it 
      loadedResource = @assetCache[filename]
      deferred.resolve( loadedResource )
      
    return deferred.promise

  ###*** 
  *remove resource from cached assets
  ###
  unLoadResource: ( fileUri )->
    #TODO : should resources be wrapped so we can deal with MANUAL reference counting etc?
    if (fileUri of @assetCache)
      delete @assetCache[ fileUri ]
	
module.exports = AssetManager


#old code for fetching local files
### 
  _localSourceFetchHandler:([store,project,path,deferred])=>
    #console.log "handler recieved #{store}/#{project}/#{path}"
    result = ""
    if not project? and path?
      if @debug
        console.log "will fetch #{path} from local (current project) namespace"
      shortName = path
      file = @project.rootFolder.get(shortName)
      result = file.content
      result = "\n#{result}\n"
      deferred.resolve(result)
    else if project? and path?
      throw new Error("non prefixed includes can only get files from current project")
###
