'use strict'
logger = require("../../logger")
logger.level = "debug"

Q = require("q")
graphDiff = require('graph-difference')
File = require "../io/file"

class PreProcessor
  #dependency resolving solved with the help of http://www.electricmonk.nl/docs/dependency_resolving_algorithm/dependency_resolving_algorithm.html
  constructor:( assetManager )->
    @assetManager = assetManager
    
    @debug = null
    @project = null
    @includePattern = /(?!\s*?#)(?:\s*?include\s*?)(?:\(?\"([\w\//:'%~+#-.*]+)\"\)?)/g
    @paramsPattern = /^(\s*)?params\s*?=\s*?(\{(.|[\r\n])*?\})/g
    
    @resolvedIncludes = []
    @unresolvedIncludes = []
    
  process: ( fileOrSource )=>
    @resolvedIncludes = []
    @resolvedIncludesFull = []
    @unresolvedIncludes = []
    
    @patternReplacers= []
    
    @processIncludes( fileOrSource )
    
    @deferred = Q.defer()
    Q.when.apply(Q, @patternReplacers).done ()=>
      #if coffeeToJs
      #  @processedResult = CoffeeScript.compile(@processedResult, {bare: true})
      
      #@processedResult = @_findParams(@processedResult) # just a test
      
      console.log "@processedResult",@processedResult
      @deferred.resolve(@processedResult)
    
    return @deferred.promise
    
  process_old:(project, coffeeToJs)=>
    coffeeToJs = coffeeToJs or false
    
    @resolvedIncludes = []
    @resolvedIncludesFull = []
    @unresolvedIncludes = []
    
    @deferred = Q.defer()
    
    ###
    TODO: checking for main file etc should not be the responsibility of the pre processor
    try
      @project = project
      mainFileName = @project.name+".coffee"
      mainFile = @project.rootFolder.get(mainFileName)
      if not mainFile?
        throw new Error("Missing main file (needs to have the same name as the project containing it)")
        
      mainFileCode = mainFile.content
      
      reqRes.addHandler("getlocalFileOrProjectCode",@_localSourceFetchHandler)
      
      
      @patternReplacers= []
      @processedResult = mainFileCode
      
      @processIncludes(mainFileName, mainFileCode)
    catch error
      @deferred.reject(error)
    ###
    
    $.when.apply($, @patternReplacers).done ()=>
      if coffeeToJs
        @processedResult = CoffeeScript.compile(@processedResult, {bare: true})
      
      @processedResult = @_findParams(@processedResult) # just a test
      #console.log "@processedResult",@processedResult
      @deferred.resolve(@processedResult)
    
    return @deferred.promise
  
  
  _findMatches:(source)=>
    source = source or ""
    
    matches = []
    match = @includePattern.exec(source)
    while match  
      matches.push(match)
      match = @includePattern.exec(source)
    return matches
  
  
  ###* 
  * handle the external geometries/object hiearchies inclusion: ie stl, amf, obj etc
  ###
  processImports:( filename, source )=>
    #TODO: how to give access to asset manager
    #STEP 1 : list all imports
    #STEP 2 : check if any import has already been cached
    #STEP 3: check if any cached data needs refreshing
    findGeomImports= (source) =>
      
    geomImports = findGeomImports( source );
  
  
  ###* 
  * handle the other projects/files inclusion
  ###
  processIncludes:( fileOrSource )=>
    if fileOrSource instanceof File
      filename = fileOrSource.name
      source = fileOrSource.content
    else
      filename = "root"
      source = fileOrSource
      
    @unresolvedIncludes.push(filename)
   
    matches =  @_findMatches(source)     
    for match in matches
      fileUri = match[1] 
      includeEntry = match[1] 
      logger.debug "include", includeEntry
      store = null
      projectName = null
      projectSubPath = null
      fullIncludePath = includeEntry
      
      if includeEntry.indexOf(':') != -1
        storeComponents = includeEntry.split(':')
        store = storeComponents[0]
        includeEntry = storeComponents[1]
      if includeEntry.indexOf('/') != -1
        fullPath = includeEntry.split('/')
        projectName = fullPath[0]
        projectSubPath = fullPath[1..fullPath.length].join('/')
      else
        if includeEntry.indexOf('.') != -1 or includeEntry.indexOf('.') == 0
          projectSubPath = includeEntry#we have a dot -> we have a file
        else
          projectName = includeEntry
          
      includeeFileName = fullIncludePath
      result = ""
      if includeeFileName in @unresolvedIncludes
        throw new Error("Circular dependency detected from #{filename} to #{includeeFileName}")
        
      if not (includeeFileName in @resolvedIncludes)
        try
          deferred = Q.defer()
          @patternReplacers.push(deferred)
          fetchResult = @_fetch_data( fileUri )
          Q.when(fetchResult).then (fileContent)=>
            logger.debug "fileContent",fileContent
            @processedResult=@processedResult.replace(match[0], fileContent)
            @processIncludes(includeeFileName, fileContent)
         
        catch error
          console.log "sdf"
          throw error
        console.log "blah", match[0]
        @resolvedIncludes.push(includeeFileName)
        
        @resolvedIncludesFull.push match[0]
      else
        @processedResult=@processedResult.replace(match[0], "")
    
    @unresolvedIncludes.splice(@unresolvedIncludes.indexOf(filename), 1)  

  _fetch_data:( fileUri )=>
    logger.debug "fetching data from : #{fileUri}"
    
    #if store is null then prefix = "local" else prefix = store
    
    ### 
    @assetManager.loadResource(  )
    .then (result) =>
      console.log "ok", result
    .fail (error) =>
      console.log "failed !", error
    ###  
    
    return @assetManager.loadResource( fileUri )
    
    ### 
      #fetch the data
      @stores[store].getFileOrProjectCode( project, path, deferred)
      
      result = deferred.promise
      return result
    catch error
      console.log "error: #{error}"
      throw new Error("#{path} : No such file or directory")###

  _buildDepsGraph:()=>
    DepGraph = require('dependency-graph').DepGraph
    
    graph = new DepGraph()
    graph.addNode('a')
    graph.addNode('b')
    graph.addNode('c')
    
    graph.addDependency('a', 'b')
    graph.addDependency('b', 'c')
    
    graph.dependenciesOf('a')
    graph.dependenciesOf('b')
    graph.dependantsOf('c')
    
    graph.overallOrder()
    graph.overallOrder(true)
      
module.exports = PreProcessor    
