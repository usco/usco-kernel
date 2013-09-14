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
merge = utils.merge



###* 
* Coffeescad module : it is NOT a node.js module, although its purpose is similar, and a part of the code
* here is ported from node modules 
###
class CModule extends File
  
  @_extensions : [] #should this be in asset manager ?
  @_cache : {} #TODO: not good, redundant with asset manager
  
  @coreModules : {} #these are predefined modules , that can be "included"/"required" by the various modules TODO: how to handle this ?
  
  #STATIC method
  @_load:(request, parent, isMain)=>
    
    #fileName = @_resolveFileName()
    module = new Module(filename, "", parent)
    
    if isMain
      #TODO : flag this module as main somewhere?
      module.id = '.'
  
    #TODO : load content ???
    return module.exports
    
  @_extensions["coffee"] = (module, fileName)->
    content = ""
    @compile(content, filename)
  
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
    
    #we have to do this hack as coffeescript reserved the "import" keyword
    #TODO: FUTURE: this is for replacing include / importGeom with a single "import statement", semi harmony compatible
    #source = source.replace("import", "include")
    
    #TODO: this coffeescript specific part should go into extension specific method
    {js, v3SourceMap, sourceMap} = CoffeeScript.compile(source, {bare: true,sourceMap:true,filename:@name})
    #logger.debug("raw source:\n",source)
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
    #logger.debug "JSIFIED script"
    #logger.debug source
    return {source:source,sourceMap:srcMap}
  
  
  ###*
  * pre fetch & cache all "geometry" used by module ie stl, amf, obj etc, (LEVEL 0 implementation)
  * 
  * 
  ###
  _resolveImports:( importGeoms )=>
    importDeferreds = (@assetManager.loadResource( fileUri, false, @name  ) for fileUri in importGeoms)
    logger.debug("Geometry import deferreds: #{importDeferreds.length}")
    
    return Q.allSettled(importDeferreds)
    #return Q.all(importDeferreds)

  ###*
  * pre fetch & cache "included" module (code import)
  * 
  ###
  _resolveIncludes:( includes )=>
    includeDeferreds = (@assetManager.loadResource( fileUri, false, @name ) for fileUri in includes)
    logger.debug("Include deferreds: #{includeDeferreds.length}")
    
    #TODO: remove, temporary
    if includes.length >0
      bla = @loadModule( includes[0] , @ )
      console.log "POUET"
      return Q.allSettled( [bla] )
    else
      d = Q.defer()
      p = d.promise
      d.resolve()
      return Q.allSettled( [p] )
    #return Q.allSettled(includeDeferreds)
  
  _resolveIncludesFull:( includes )=>
    console.log "lkjlkj"
    includeDeferreds = (@assetManager.loadResource( fileUri ) for fileUri in includes)
    logger.debug("Include deferreds: #{includeDeferreds.length}")
    
    d = Q.allSettled(includeDeferreds)
    d.then (includes)=>
  
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
  loadModule:( request, parent, isMain )=>
    fileName = request
    isMain = isMain or false
    logger.info( "Loading module", fileName )
    
    exportsDeferred = Q.defer()
    
    contentPromise = @assetManager.loadResource(fileName, false, parent.name)
    
    contentPromise.then (content) =>
      logger.info("module content loaded", content)
      fileName = content[0]
      fileContent = content[1]
      module = new CModule(fileName, fileContent, @)
      module.assetManager = @assetManager
      @children.push(module)
      bla = module.doAll()
      bla.then ( exports ) =>
        console.log "in caller : exports", exports
        exportsDeferred.resolve( [fileName, exports] )
    ###
    if isMain
      #TODO : flag this module as main somewhere?
      module.id = '.'###
  
    return exportsDeferred.promise
  
  
  ############################
  ###Methods that get injected into evaled module code###
  
  include:( uri )=>
    #TODO: do module loading here ?
    logger.debug "within script: include from #{uri}"
    uri = @assetManager._toAbsoluteUri( uri, @name ) #TODO : (YUCK usage of private method) !!!! we are getting RESOLVED uri's back, so all previously relative paths are absolute!
    
    resource = CModule._cache[uri]
    if resource instanceof Error
      throw resource
    logger.debug "include result",CModule._cache
    return resource
  
  ###*
  * method that gets "injected" into modules source, the one that actually is called
  * currently it is one big hack : needed resources have already been loaded (async) when this method
  * can get called, thus this one only returns (sync) data from cache :
  * @return {Object} either the loaded resource, or an error instance, indicated why loading it failed
  ###
  importGeom:( uri )=>
    logger.debug "within script:  import geometry from #{uri}"
    uri = @assetManager._toAbsoluteUri( uri, @name ) #TODO : (YUCK usage of private method) !!!! we are getting RESOLVED uri's back, so all previously relative paths are absolute!

    resource = CModule._cache[uri]
    if resource instanceof Error
      throw resource
    return resource
  
  
  ###*
  * wraps module , injecting params such as exports, include/import/require method etc
  * 
  ###
  wrap:(script)->
    #TODO : what should be wrap: original code or converted ?
    #more likely the modified one, as this changes the ast?
    wrapped = """
    return (function ( exports, include, importGeom, module, assembly, __filename)
    {
      //console.log("include",include,"importGeom",importGeom);
      //clear log entries
      log = {}
      log.entries = []
      
      #{script}
      
     });
    """
    #TODO: add log , etc to includables (ie useable by include method above)
    ##{@autoExports}@autoExports+ #YUCK !!! TODO: better way to do this
    return wrapped
  
  compile:( source )=>
    logger.info("compiling module #{@name}")
    wrapped = @wrap(source) 
    #logger.debug("wrapped", wrapped)
    
    #TODO: should this be here:
    @assembly = {}
    
    fn = null
    try
      f = new Function( wrapped )
      fn = f()
      logger.debug("============START MODULE #{@name}===============")
      res = fn( @exports, @include, @importGeom, @, @assembly, @name)
      logger.debug("============END   MODULE #{@name}===============")
      logger.info("Module #{@name} EXPORTS:", @exports)
    catch error
      logger.error("Compiling module #{@name} failed: #{error}")
      throw error
    #f = new Function(["module","assembly"], wrapper )
    #toto = f.apply(null, [module,assembly])
    
    logger.info("done compiling module #{@name}")
    return fn
  
  #temporary, just for tests
  doAll:->
    sourceData = @_prepareSource( @content )
    moduleData = @_analyseSource(sourceData.source)
    
    #TODO: errmm not sure where this should be: it needs moduleData, but should also be part of the source
    @autoExports = @_autoGenerateExports( moduleData.rootElements )
    
    onSuccess = (importResults, includeResults)=>
      #console.log("imports, includes ok")
      #console.log("importResults", importResults)
      #console.log("includeResults", includeResults)
      #importsIncludes = merge( importResults, includeResults )
      
      importsIncludes = importResults.value.concat( includeResults.value)
      #console.log "importsIncludes", importsIncludes
      
      
      for importResult in importsIncludes
        #console.log "pouet", importResult
        if importResult.state is "fulfilled"
          value = importResult.value
          if value?
            uri = value[0]
            resource = value[1]
            CModule._cache[uri] = resource
            #console.log "import success", uri
          
        if importResult.state is "rejected"
          reason = importResult.reason
          if reason?
            uri =  reason[0] 
            error = reason[1]
            
            #console.log "import failure", uri, reason
            CModule._cache[uri] = error
      
        
      #console.log "Cache:\n",CModule._cache
      d = Q.defer()
      d.resolve()
      return d.promise
      
    onFailure = (bla, bli)=>
      console.log("on fail",bla)  
    
    #TODO : wowsers !!! at this point we only have raw data, with NO clue of the original file name !!!!! that must be kept somewhere !
    
    importDeferreds = @_resolveImports( moduleData.importGeoms )
    
    #TODO: includes need to import/compile/get exports
    includeDeferreds = @_resolveIncludes( moduleData.includes )
    
    #CRUCIAL
    resourcesPromise = Q.allSettled([importDeferreds, includeDeferreds])
    allLoadedPromise = resourcesPromise.spread(onSuccess, onFailure)
    
    finalPromise = allLoadedPromise.then ()=>
      #load module
      #compile module
      #return exports
      @compile(sourceData.source)
      console.log "exports, current module", @exports
      return @exports
   
    return finalPromise
  
  ############################
  #All things related to code re-write from "visual" here
  ###TODO: 
  1 - find point where object's last transform is present
  2 - normalize transforms list (two translates in a row can be conbined, etc)
  2.b - generate any other required code transforms
  3 - inject code
  ###

module.exports = CModule