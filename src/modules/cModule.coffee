'use strict'
assert = require('assert').ok
CoffeeScript =  require('coffee-script')
esprima = require "esprima"
Q = require("q")
path = require "path"

logger = require("../../logger")
logger.level = "debug"
File = require './file'
ASTAnalyser = require "../compiler/astUtils"

utils = require "../utils"
btoa = utils.btoa
merge = utils.merge

THREE = require("three")


#TODO: have something like ? for imports ?
#require.cache

#TODO: put this in pathUtils?
tryCoreModules=( baseName, exts )=>
  for ext in exts
    fileName = baseName+".#{ext}"
    console.log "fileName", fileName
    if fileName in CModule.coreModules
      return fileName
  return null

###* 
* Coffeescad module : it is NOT a node.js module, although its purpose is similar, and a part of the code
* here is ported from node modules 
###
class CModule extends File
  @_cache : {} #TODO: remove this ? not good, redundant with asset manager
  @_pathCache: {}
  @_extensions: {} #should this be in asset manager ?
  @coreModules : {} #these are predefined modules , that can be "included"/"required" by the various modules TODO: how to handle this ?
  
  @coreModules["shapes"] = require("../shapes/shapes")
  @coreModules["maths"] = require("../maths/maths")
  @coreModules["assembly"] = new THREE.Object3D() #TODO : no good ! we should not rely excplitely on three.js here
  
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
  
  @_extensions["litcoffee"] = (module, fileName)->
    content = ""
    @compile(content, filename)
 
  @_extensions["js"] = (module, fileName)->
    content = ""
    @compile(content, filename)
 
  @_findPath = (request, paths) ->
    #VERY close to the node.js one
    #resolution order:
    #1 - if path is neither relative nor absolute:
    #  a- look in core modules (if no extension is given, try all supported extensions)
    #  b- look in modules relative to current (same as ./<ModuleName>) (if no extension is given, try all supported extensions)
    #2 - if path is relative or absolute
    #  a- if no extension is given, try all supported extensions
    #  b- else, just resolve
    
    exts = Object.keys(CModule._extensions)
    
    if (request.charAt(0) is '/')
      paths = ['']
  
    trailingSlash = (request.slice(-1) is '/')
  
    cacheKey = JSON.stringify({request: request, paths: paths});
    if CModule._pathCache[cacheKey]
      return CModule._pathCache[cacheKey]
    
    curExt = path.extname(request)
    basePath = path.basename(request)
    console.log "exts",exts
    
    fileName = null
    
    if not fileName
      fileName = tryCoreModules(basePath, exts)
      console.log "tryCoreModules" , fileName
    if not fileName
      fileName = tryExtensions(path.resolve(basePath, 'index'), exts)
    
    if fileName
      CModule._pathCache[cacheKey] = fileName
      return fileName
      
    return false

  
  constructor:(name, content, parent)->
    super( name, content )
    @parent = parent or null
    @children = []
    
    @loaded =  false #if @content == null then false else true
    #if true, the module system will attempt to capture all root elements and add them to module.exports
    @generateExports = true
    @autoExports = ""
    @exports = {}
    
    @_ASTAnalyser = new ASTAnalyser()
    @assetManager = null
    
    #TODO: should this be here: it might make more sense to have it at class level ? 
    @assembly = {}
    

  ###*
  * convert relative to absolute file paths
  * 
  ###
  _resolveFileName:( uri, parent)=>
  
  ###*
  * prepare the source for compiling : convert coffee->js if needed , inject dependencies etc
  * @param {String} source the original source code
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
    #logger.debug "JSIFIED script"
    #logger.debug source
    return {source:source,sourceMap:srcMap}
  
  ###*
  * pre fetch & cache all "geometry" used by module ie stl, amf, obj etc, (LEVEL 0 implementation)
  * 
  * @return {object} a deferred list of geometry imports with both sucessed and failures
  ###
  _prefetchImports:( importGeoms )=>
    importDeferreds = (@assetManager.loadResource( fileUri, @name ) for fileUri in importGeoms)
    logger.debug("Geometry import deferreds: #{importDeferreds.length}")
    
    return Q.allSettled(importDeferreds)
    #return Q.all(importDeferreds)

  ###*
  * pre fetch & cache "included" module (code import)
  * @return {object} a deferred list of includes with both sucessed and failures
  ###
  _prefetchIncludes:( includes )=>
    for fileUri in includes
      #TODO: this needs to use the correct content resolution method (chek if uri is in coremodules, check by extensions etc)
      if fileUri of CModule.coreModules
        console.log "attempting to include core module", fileUri
    
    includeDeferreds = (@assetManager.loadResource( fileUri, @name ) for fileUri in includes)
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
  
  ###*
  * add level 0 (script root) variable , method & class definitions to module.exports
  * if the user has not defined exports itself, all the elements at script root get added to exports
  * @param {String} rootElements the original source code
  * @return {String} a string containing all added exports 
  ###
  _autoGenerateExports:( rootElements )=>
    #generate auto exports script
    autoExportsSrc = "try{ if(Object.keys(module.exports).length === 0){"
    #autoExportsSrc += "try{\n if(!'#{elem}' in module.exports){ module.exports.#{elem}=#{elem}; console.log('OI',module.exports); }\n}catch(e) {console.log('POUET',e)}" for elem in rootElements
    autoExportsSrc += """
    try{
      if(!('#{elem}' in module.exports) )
      { 
        module.exports.#{elem}=#{elem}; 
       }
    }catch(e){} 
    """ for elem in rootElements
    autoExportsSrc += "}}catch(e){}"
    
    logger.debug("autoExports:\n", autoExportsSrc) 
    return autoExportsSrc
  
  _analyseSource:( source )->
    ast = esprima.parse(source, { range: false, loc: false , comment:false})
    moduleData = @_ASTAnalyser.analyseAST( ast )
    
    return moduleData
  
  ############################
  loadModule:( request, parent, isMain )=>
    fileName = request
    isMain = isMain or false
    logger.info( "Loading module", fileName )
    
    exportsDeferred = Q.defer()
    
    contentPromise = @assetManager.loadResource(fileName, parent.name)
    
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
  ###Methods that get injected into "evaled" module code###
  
  include:( uri )=>
    #TODO: do module loading here ?
    logger.debug "within script: include from #{uri}"
    #TODO: this needs to use the correct content resolution method (chek if uri is in coremodules, check by extensions etc)
    if uri of CModule.coreModules
      console.log "attempting to include core module", uri
      return  CModule.coreModules[uri]
      
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
  * @return {String}  the original source, wrapped inside the wrapped
  ###
  wrap:(script)->
    #TODO : what should be wrap: original code or converted ?
    #more likely the modified one, as this changes the ast?
    #TODO:how to do logging?
    wrapped = """
    return (function ( exports, include, importGeom, module, __filename)
    {
      
      //hack for now, otherwise getting weird JSON circular reference errors ???
      assembly =  {} //include("assembly");
      assembly.elems =[]
      assembly.add = function( bla ){
        assembly.elems.push(bla);
      }
      
      //API
      maths = include("maths");
      shapes = include("shapes");
      
      //extract shapes to 'current' namespace
      var __apiInjector__ = {}
      
      for (var key in shapes) { __apiInjector__[key] = shapes[key]; }
      for (var key in maths)  { __apiInjector__[key] = maths[key];  }
      //otherwise ... ye gads ! var Cube = shapes["Cube"]; for EACH key in shapes, maths etc
      
      with(__apiInjector__)
      {
        #{script}
      }
      
      //add auto generated exports, if needed
      #{@autoExports}
     });
    """
    #TODO: add log , etc to includables (ie useable by include method above)
    ##{@autoExports}+ #YUCK !!! TODO: better way to do this
    return wrapped
  
  compile:( source )=>
    logger.info("compiling module #{@name}")
    wrapped = @wrap(source) 
    logger.debug("wrapped", wrapped)
    fn = null
    try
      f = new Function( wrapped )
      fn = f()
      logger.debug("============START MODULE #{@name}===============")
      #res = fn( @exports, @include, @importGeom, @, @name)
      res = fn.call(fn, @exports, @include, @importGeom, @, @name, ) #we use call to force "this", to the current module
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
    if @generateExports
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
    
    importDeferreds = @_prefetchImports( moduleData.importGeoms )
    
    #TODO: includes need to import/compile/get exports
    includeDeferreds = @_prefetchIncludes( moduleData.includes )
    
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