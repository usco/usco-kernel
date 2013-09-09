'use strict'
logger = require("../../logger")
logger.level = "debug"

#CoffeeScript =  require('coffee-script-redux') #redux cannot yet handler "super" calls, so useless in our case, sadly
CoffeeScript =  require('coffee-script')
esprima = require "esprima"
esmorph = require "esmorph"
#require "escodegen"
Q = require("q")
#graphDiff = require('graph-difference')
#DepGraph = require('dependency-graph').DepGraph

File = require "../io/file"
ASTAnalyser = require "./astUtils"


#resources such as geometry (stl, amf, etc) , text files etc are LEAVES in the graph, no depency resolution is made from them
#resource such as code (coffee, js, litcoffee, ultishape etc) can be either LEAVES (no dependencies) or not, but dependency resolution is ALWAYS done from them

#TODO: perhaps we could "cheat" around the async loading issues by checking out, via the AST if an class or method containing imports ACTUALLY GETS INSTANCIATED
#TODO: we need to track changes between subsequent compiles : if a node in the AST has change but the resulting geometry would be the same, no need to re compile !
#TODO: perhaps work on a "pseudo fake"(!!) import system : preload resource and store them, AS WELL AS THE IMPORT ERRORS, then have a REAL import method that gets called
#on script evaluation, that just returns either the actual resource or the error in a SYNC manner when script is evaluated

class PreProcessor
  #dependency resolving solved with the help of http://www.electricmonk.nl/docs/dependency_resolving_algorithm/dependency_resolving_algorithm.html
  constructor:( assetManager )->
    @assetManager = assetManager
    @aSTAnalyser = new ASTAnalyser()
    
    @debug = null
    
    @resolvedIncludes = []
    @unresolvedIncludes = []
    
  process: ( fileOrSource )=>
    @resolvedIncludes = []
    @resolvedIncludesFull = []
    @unresolvedIncludes = []
    @patternReplacers= []

    source = @_prepareScript( fileOrSource )
    ast = @_preOptimise( source )
    moduleData = @aSTAnalyser._walkAst( ast )
    
    importDeferreds = @resolveImports( moduleData.importGeoms )
    includeDeferreds = @resolveIncludes( moduleData.includes )
    
    #@processIncludes( fileOrSource )
    return Q.all([importDeferreds, includeDeferreds])
    
  
  ###*
  * prepare the source for compiling : convert to coffeescript, inject dependencies etc
  ###
  _prepareScript:( source )->
    #standard coffeescript
    #TODO: fileName needs to match module id/name
    {js, v3SourceMap, sourceMap} = CoffeeScript.compile(source, {bare: true,sourceMap:true,filename:"output.js"})
    logger.debug("raw source",source)
              
    source = js 
    #console.log("js", js, "v3map", v3SourceMap, "map", sourceMap)
    console.log "v3map", v3SourceMap
    
    moduleId = "myFileName.coffee" #TODO: use actual file name
    srcMap = JSON.parse( v3SourceMap )
    #TODO: this needs to contain ALL included files
    srcMap.sources = []
    srcMap.sources.push( moduleId ) 
    #srcMap.sourcesContent = [code.value];
    srcMap.file = "toto"
    datauri = 'data:application/json;charset=utf-8;base64,'+btoa(JSON.stringify(srcMap))
    
    source += "\n//@ sourceMappingURL=" + datauri

    console.log "v3map2", srcMap
    logger.debug "JSIFIED script"
    logger.debug source
    return source
    
  ###*
  * Make sure there have been ACTUAL changes to the code before doing the bulk of the work (ignore comment changes, whitespacing etc)
  ###
  _preOptimise:( source )=>
    
    ast = esprima.parse(source, { range: false, loc: false , comment:false})
    logger.debug("AST", ast)
    
    #TODO: move this to per module ?
    if (@_prevAst?)
      #TODO: remove stringification step if possible
      jsonAst1 = JSON.stringify(ast)
      #prevAst is already stringified
      jsonAst2 = @_prevAst
      isDifferent = (jsonAst1 == jsonAst2)
      logger.info(" old ast is same as new ast", isDifferent)
      @reEvalutate = not isDifferent
    else 
      jsonAst1 = JSON.stringify(ast)
    @_prevAst = jsonAst1
    return ast
    
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
  
  compile:()->
    wrapped = @wrap(@content)
        
    f = new Function( wrapped )
    fn = f()
    
    fn( @exports, @include, @, @fileName) 
  
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


#TODO: how to handle these kind of things : not part of globals on NODE , but ok in browsers?
btoa = (str) ->
  buffer = undefined
  if str instanceof Buffer
    buffer = str
  else
    buffer = new Buffer(str.toString(), "binary")
  buffer.toString "base64"


module.exports = PreProcessor    
