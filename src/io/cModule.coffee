'use strict'
CoffeeScript =  require('coffee-script')
esprima = require "esprima"
Q = require("q")

logger = require("../../logger")
logger.level = "debug"
File = require './File'
ASTAnalyser = require "./astUtils"
utils = require "../utils"
btoa = utils.btoa



###* 
* Coffeescad module : it is NOT a node.js module, although its purpose is similar, and a part of the code
* here is ported from node modules 
###
class CModule extends File
  
  @_extensions = [] #should this be in asset manager ?
  @_extensions["coffee"] = ""
  
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
    @exports = {}
    
    @loaded = false
    @exports = {}
    
    @parent = null
    @children = []
    
    @_ASTAnalyser = new ASTAnalyser()

  
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
    {js, v3SourceMap, sourceMap} = CoffeeScript.compile(source, {bare: true,sourceMap:true,filename:"output.js"})
    logger.debug("raw source",source)
              
    source = js 
    
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
  * pre fetch & cache all "geometry" used by module ie stl, amf, obj etc, (LEVEL 0 implementation)
  * 
  * 
  ###
  _resolveImports:( importGeoms )=>
    importDeferreds = (@assetManager.loadResource( fileUri ) for fileUri in importGeoms)
    logger.debug("Geometry import deferreds: #{importDeferreds.length}")
    return Q.all(importDeferreds)

  ###*
  * pre fetch & cache "included" module (code import)
  * 
  ###
  _resolveIncludes:( includes )=>
    includeDeferreds = (@assetManager.loadResource( fileUri ) for fileUri in includes)
    logger.debug("Include deferreds: #{includeDeferreds.length}")
    return Q.all(includeDeferreds)
  
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

    moduleData = @aSTAnalyser._walkAst( ast )
    importDeferreds = @_resolveImports( moduleData.importGeoms )
    includeDeferreds = @_resolveIncludes( moduleData.includes )
  
  
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
  