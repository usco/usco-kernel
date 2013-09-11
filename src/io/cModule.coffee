'use strict'
assert = require('assert').ok
CoffeeScript =  require('coffee-script')
esprima = require "esprima"
Q = require("q")

logger = require("../../logger")
logger.level = "debug"
File = require './file'
ASTAnalyser = require "../compiler/astUtils"
utils = require "../utils"
btoa = utils.btoa


###* 
* Coffeescad module : it is NOT a node.js module, although its purpose is similar, and a part of the code
* here is ported from node modules 
###
class CModule extends File
  
  @_extensions = [] #should this be in asset manager ?
  
  #STATIC method
  @_load:(request, parent, isMain)=>
    
    fileName = @_resolveFileName()
    module = new Module(filename, "", parent)
    
    if isMain
      #TODO : flag this module as main somewhere?
      module.id = '.'
  
    #TODO : load content ???
    return module.exports
  
  constructor:(name, content, parent)->
    super( name, content )
    @parent = parent or null
    @children = []
    
    @loaded =  false #if @content == null then false else true
    @exports = {}
    
    @_ASTAnalyser = new ASTAnalyser()
    @assetManager = null

  ###*
  * convert relative to absolute file paths
  * 
  ###
  _resolveFileName:( uri, parent)=>
  
  ###*
  * prepare the source for compiling : convert coffee->js if needed , inject dependencies etc
  * @param {String} the original source code
  * @return {String} the modified, possibly converted source code
  ###
  _prepareSource:( source )->
    if not source?
      throw new Error("No source provided.")
    logger.debug("Preparing source")
    #TODO: this coffeescript specific part should go into extension specific method
    {js, v3SourceMap, sourceMap} = CoffeeScript.compile(source, {bare: true,sourceMap:true,filename:"output.js"})
    logger.debug("raw source",source)
              
    source = js 
    
        
    moduleId = @name #TODO: use actual file name
    srcMap = JSON.parse( v3SourceMap )
    #TODO: this needs to contain ALL included files
    srcMap.sources = []
    srcMap.sources.push( moduleId ) 
    #srcMap.sourcesContent = [code.value];
    srcMap.file = "toto"
    datauri = 'data:application/json;charset=utf-8;base64,'+btoa(JSON.stringify(srcMap))
    #source += "\n//@ sourceMappingURL=" + datauri

    #console.log "v3map2", srcMap
    logger.debug "JSIFIED script"
    logger.debug source
    return {source:source,sourceMap:srcMap}
  
  
  ###*
  * pre fetch & cache all "geometry" used by module ie stl, amf, obj etc, (LEVEL 0 implementation)
  * 
  * 
  ###
  _resolveImports:( importGeoms )=>
    importDeferreds = (@assetManager.loadResource( fileUri ) for fileUri in importGeoms)
    logger.debug("Geometry import deferreds: #{importDeferreds.length}")
    
    return Q.allSettled(importDeferreds)
    #return Q.all(importDeferreds)

  ###*
  * pre fetch & cache "included" module (code import)
  * 
  ###
  _resolveIncludes:( includes )=>
    includeDeferreds = (@assetManager.loadResource( fileUri ) for fileUri in includes)
    logger.debug("Include deferreds: #{includeDeferreds.length}")
    return Q.allSettled(includeDeferreds)
  
  ###*
  * pre fetch & cache all "geometry" used by module ie stl, amf, obj etc, (LEVEL 0 implementation)
  * 
  * 
  ###
  _resolveImports2:( importGeomsList )=>
    console.log "importGeomsList",importGeomsList
    imports = {}
    for fileUri in importGeomsList
      imports[fileUri] = @assetManager.loadResource( fileUri )
    #imports = ({fileUri : @assetManager.loadResource( fileUri )} for fileUri in importGeoms)
    logger.debug("Geometry imports : #{Object.keys(imports).length}" )
    return imports

  ###*
  * pre fetch & cache "included" module (code import)
  * 
  ###
  _resolveIncludes2:( includesList )=>
    includes = {}
    for fileUri in includesList
      includes[fileUri] = @assetManager.loadResource( fileUri )
    #includeDeferreds = (@assetManager.loadResource( fileUri ) for fileUri in includes)
    logger.debug("Includes: #{Object.keys(includes).length}")
    return includes #Q.all(includeDeferreds)
  
  ###*
  * add level 0 (script root) variable , method & class definitions to module.exports
  * if the user has not defined exports itself, all the elements at script root get added to exports
  * @param {String} rootElements the original source code
  * @return {String} a string containing all added exports 
  ###
  _autoGenerateExports:( rootElements )=>
    #generate auto exports script
    autoExportsSrc = ""
    autoExportsSrc += "exports.#{elem}=#{elem};\n" for elem in rootElements
    logger.debug("autoExports", autoExportsSrc) 
    
    return autoExportsSrc
  
  _analyseSource:( source )->
    ast = esprima.parse(source, { range: false, loc: false , comment:false})
    moduleData = @_ASTAnalyser._walkAst( ast )
    
    return moduleData
  
  ############################
  
  include:( uri )->
    console.log "include : #{uri}"
    
  importGeom:( uri )->
    console.log "import geometry at #{uri}"
  
  ###*
  * wraps module , injecting params such as exports, include/import/require method etc
  * 
  ###
  wrap:(script)->
    wrapped = """
    return (function ( exports, include, importGeom,  module, __filename)
    {
      #{script}
      console.log("exports",exports, "module",module);
     });
    """
    return wrapped
  
  compile:->
    wrapped = @wrap(@content)
        
    f = new Function( wrapped )
    fn = f()
    
    fn( @exports, @include, @importGeom @, @name)
      
    #f = new Function(["module","assembly"], wrapper )
    #toto = f.apply(null, [module,assembly])
  
  #temporary, just for tests
  doAll:->
    sourceData = @_prepareSource( @content )
    moduleData = @_analyseSource(sourceData.source)
    
    ###
    imports = @_resolveImports2( moduleData.importGeoms )
    includes = @_resolveIncludes2( moduleData.includes )
    console.log "imports", imports
    console.log "includes", includes
    #for uri, deferred of imports
    ###
    
    onSuccess = (bla, bli)=>
      console.log("on sucess",bla)
      
    onFailure = (bla, bli)=>
      console.log("on fail",bla)  
    
    importDeferreds = @_resolveImports( moduleData.importGeoms )
    includeDeferreds = @_resolveIncludes( moduleData.includes )
    
    resourcesDeferred = Q.allSettled([importDeferreds, includeDeferreds])
    
    resourcesDeferred.then (res)->
      console.log "i am here0", res
    
    finalDeferred = resourcesDeferred.spread((bla, bla2)=>
      #TODO : wowsers !!! at this point we only have raw data, with NO clue of the original file name !!!!! that must be kept somewhere !
      #@cachedResources
      console.log "bla0", bla[0][0]
      console.log "bla", bla.length
      console.log "bla2", bla2.length
      
      return "pouet"
    )
    
    finalDeferred.then (res)->
      console.log "i am here", res
   
    return
    
  
  
  ############################
  #All things related to code re-write from "visual" here
  ###TODO: 
  1 - find point where object's last transform is present
  2 - normalize transforms list (two translates in a row can be conbined, etc)
  2.b - generate any other required code transforms
  3 - inject code
  ###

module.exports = CModule