'use strict'

#require "esprima"
#require "esmorph"
#require "escodegen"

class PreProcessor
  #dependency resolving solved with the help of http://www.electricmonk.nl/docs/dependency_resolving_algorithm/dependency_resolving_algorithm.html
  constructor:()->
    @debug = null
    @project = null
    @includePattern = /(?!\s*?#)(?:\s*?include\s*?)(?:\(?\"([\w\//:'%~+#-.*]+)\"\)?)/g
    @paramsPattern = /^(\s*)?params\s*?=\s*?(\{(.|[\r\n])*?\})/g
    
    @resolvedIncludes = []
    @unresolvedIncludes = []
    
  process: ( source )=>
    @resolvedIncludes = []
    @resolvedIncludesFull = []
    @unresolvedIncludes = []
    
    @deferred = $.Deferred()
    $.when.apply($, @patternReplacers).done ()=>
      if coffeeToJs
        @processedResult = CoffeeScript.compile(@processedResult, {bare: true})
      
      @processedResult = @_findParams(@processedResult) # just a test
      #console.log "@processedResult",@processedResult
      @deferred.resolve(@processedResult)
    
    return @deferred.promise()
    
  process_old:(project, coffeeToJs)=>
    coffeeToJs = coffeeToJs or false
    
    @resolvedIncludes = []
    @resolvedIncludesFull = []
    @unresolvedIncludes = []
    
    @deferred = $.Deferred()
    
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
    
    return @deferred.promise()
  
  
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
  processIncludes:(filename, source)=>
    @unresolvedIncludes.push(filename)
   
    matches =  @_findMatches(source)     
    for match in matches
      includeEntry = match[1] 
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
          
      #console.log("store: #{store}, project: #{projectName}, subpath: #{projectSubPath}")
      includeeFileName = fullIncludePath
      result = ""
      if includeeFileName in @unresolvedIncludes
        throw new Error("Circular dependency detected from #{filename} to #{includeeFileName}")
        
      if not (includeeFileName in @resolvedIncludes)
        try
          deferred = $.Deferred()
          @patternReplacers.push(deferred)
          fetchResult = @_fetch_data(store,projectName,projectSubPath, deferred)
          $.when(fetchResult).then (fileContent)=>
            @processedResult=@processedResult.replace(match[0], fileContent)
            @processIncludes(includeeFileName, fileContent)
            
        catch error
          throw error
        @resolvedIncludes.push(includeeFileName)
        @resolvedIncludesFull.push match[0]
      else
        @processedResult=@processedResult.replace(match[0], "")
    
    @unresolvedIncludes.splice(@unresolvedIncludes.indexOf(filename), 1)  

  _fetch_data:(store,project,path,deferred)=>
    #console.log "fetching data from Store: #{store}, project: #{project}, path: #{path}"
    try
      fileOrProjectRequest = "#{store}/#{project}/#{path}"
      if store is null then prefix = "local" else prefix = store
      
      #fetch the data
      @stores[store].getFileOrProjectCode( project, path, deferred)
      
      result = deferred.promise()
      return result
    catch error
      console.log "error: #{error}"
      throw new Error("#{path} : No such file or directory")

      
module.exports = PreProcessor    
