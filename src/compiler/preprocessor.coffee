'use strict'
logger = require("../../logger")
logger.level = "debug"

#CoffeeScript =  require('coffee-script-redux') #redux cannot yet handler "super" calls, so useless in our case, sadly
CoffeeScript =  require('coffee-script')
esprima = require "esprima"
esmorph = require "esmorph"
#require "escodegen"
Q = require("q")
graphDiff = require('graph-difference')
#DepGraph = require('dependency-graph').DepGraph

File = require "../io/file"


#resources such as geometry (stl, amf, etc) , text files etc are LEAVES in the graph, no depency resolution is made from them
#resource such as code (coffee, js, litcoffee, ultishape etc) can be either LEAVES (no dependencies) or not, but dependency resolution is ALWAYS done from them

#TODO: perhaps we could "cheat" around the async loading issues by checking out, via the AST if an class or method containing imports ACTUALLY GETS INSTANCIATED
#TODO: we need to track changes between subsequent compiles : if a node in the AST has change but the resulting geometry would be the same, no need to re compile !

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

    source = @_prepareScript( fileOrSource )
    ast = @_preOptimise( source )
    moduleData = @_walkAst( ast )
    
    importDeferreds = @resolveImports( moduleData.importGeoms )
    includeDeferreds = @resolveIncludes( moduleData.includes )
    
    #@processIncludes( fileOrSource )
    
    return Q.all([importDeferreds, includeDeferreds])
    
  
  _findMatches:(source)=>
    source = source or ""
    
    matches = []
    match = @includePattern.exec(source)
    while match  
      matches.push(match)
      match = @includePattern.exec(source)
    return matches
  
  isInclude: (node)->
    c = node.callee
    return (c and node.type == 'CallExpression' and c.type == 'Identifier' and c.name == 'include')
  
  isImportGeom: (node)->
    c = node.callee
    return (c and node.type == 'CallExpression' and c.type == 'Identifier' and c.name == 'importGeom')
  
  isParams: (node)->
    #TODO: fix this 
    c = node.callee
    if c?
      name = c.name
    #console.log "NODE", node, "callee",c, "Cname", name, "type",node.type, "name", node.name
    return (c and node.type == 'VariableDeclaration' and c.type == 'Identifier' and c.name == 'params')
  
  ###*
  * prepare the source for compiling : convert to coffeescript, inject dependencies etc
  ###
  _prepareScript:( source )->
    #standard coffeescript
    #{js, v3SourceMap, sourceMap} = CoffeeScript.compile(source, {bare: true,sourceMap:true})
    logger.debug("raw source",source)
    js = CoffeeScript.compile(source, {bare: true})
    source = js 
    #console.log("js", js, "v3map", v3SourceMap, "map", sourceMap)
    logger.debug "JSIFIED script"
    logger.debug source
    return source
    
  ###*
  * Make sure there have been ACTUAL changes to the code before doing the bulk of the work (ignore comment changes, whitespacing etc)
  ###
  _preOptimise:( source )=>
    ast = esprima.parse(source, { range: false, loc: false , comment:false})
    logger.debug("AST", ast)
    #console.log("AST",ast)
    return ast
    ###
    if (@_prevAst?)
      #TODO: remove stringification step if possible
      jsonAst1 = JSON.stringify(ast)
      jsonAst2 = JSON.stringify(@_prevAst)
      isDifferent = (jsonAst1 == jsonAst2)
      logger.info(" old ast is same as new ast", isDifferent)
      @reEvalutate = not isDifferent
    @_prevAst = ast###
  
  
  _walkAst:( ast )=>
    
    traverse = (object,limit,level, visitor, path) =>
      #console.log "level",level, "limit", limit, "path",path
      #limit = limit or 2
      #level = level or 0
      #console.log "visitore", visitor
      if level < limit or limit == 0
        key = undefined
        child = undefined
        path = []  if typeof path is "undefined"
        visitor.call null, object, path, level
        subLevel = level+1
        for key of object
          if object.hasOwnProperty(key)
            child = object[key]
            traverse child, limit, subLevel, visitor, [object].concat(path)  if typeof child is "object" and child isnt null
    
    #get all the things we need from ast
    rootElements = []
    includes = []
    importGeoms = []
    params = [] #TODO: only one set of params is allowed, this needs to be changed
    
    
    #ALL of the level 0 (root level) items need to be added to the exports, if so inclined
    traverse ast,0,0, (node, path, level) =>
      name = undefined
      parent = undefined
      
      #console.log("level",level)
      
      if node.type is esprima.Syntax.VariableDeclaration and level is 2
        console.log("VariableDeclaration")
        for dec in node.declarations
          decName = dec.id.name
          #console.log "ElementName", decName
          rootElements.push( decName )
    
      if @isInclude( node )
        console.log("IsInclude",node.arguments[0].value)
        includes.push( node.arguments[0].value )
      
      if @isImportGeom( node )
        console.log("IsImportGeom",node.arguments[0].value)
        importGeoms.push( node.arguments[0].value )
      
      if @isParams( node )
        console.log("isParams",node.arguments[0].value)
        params.push( node.arguments[0].value )
    
    console.log("rootElements", rootElements)
    console.log("includes",includes)
    console.log("importGeoms",importGeoms)   
    console.log("params",params)    
    
    return {rootElements:rootElements, includes:includes, importGeoms:importGeoms}
  
  ###*
  * add level 0 (script root) variable , method & class definitions to module.exports
  * 
  ###
  generateExports:( rootElements )=>
    #generate auto exports script
    autoExportsSrc = ""
    autoExportsSrc += "exports.#{elem}=#{elem};\n" for elem in rootElements
    console.log(autoExportsSrc) 
  
  ###*
  * pre fetch & cache all "geometry" used by module ie stl, amf, obj etc, (LEVEL 0 implementation)
  * 
  ###
  resolveImports:( importGeoms )=>
    importDeferreds = (@assetManager.loadResource( fileUri ) for fileUri in importGeoms)
    logger.debug("Geometry import deferreds: #{importDeferreds.length}")
    return Q.all(importDeferreds)

  ###*
  * pre fetch & cache "included" module (code import)
  * 
  ###
  resolveIncludes:( includes )=>
    includeDeferreds = (@assetManager.loadResource( fileUri ) for fileUri in includes)
    logger.debug("Include deferreds: #{includeDeferreds.length}")
    return Q.all(includeDeferreds)
  
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
          fetchResult = @_fetch_data( fileUri )
          @patternReplacers.push(fetchResult)
          
          fetchResult
          .then (fileContent)=>
            logger.debug "fileContent",fileContent
            @processedResult=@processedResult.replace(match[0], fileContent)
            @processIncludes(includeeFileName, fileContent)
          .catch (error)=>
            logger.error("Errrrooor", error)
         
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

  _buildDepsGraph:()=>
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
