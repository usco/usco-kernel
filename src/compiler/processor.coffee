'use strict'

logger = require("../../logger")
logger.level = "info"
#CoffeeScript =  require('coffee-script-redux') #redux cannot yet handler "super" calls, so useless in our case, sadly
CoffeeScript =  require('coffee-script')
Q = require("q")
esprima = require "esprima"
esmorph = require "esmorph"
#require "escodegen"
THREE = require 'three'

shapesKernel = require '../shapes/api'

#TODO: add handling of simple "sub" script/ shape script, (without root assembly etc)

class Processor
  #processes a csg script
  constructor:->
    #previous ast
    @_prevAst = null
    #do we need to reevaluate script?
    @reEvalutate = true
        
  processScript:( script, params )-> 
    @script = script
    @params = params  
    
    @deferred = Q.defer()    
    
    @generateAssembly()
    
    return @deferred.promise
    
  generateAssembly: =>
    @processing = true
    try
      @_prepareScript()
      @_preOptimise()
      @_upgradeScript()
      
      rootAssembly = @evaluateScript(@script, @params)
      @deferred.resolve( rootAssembly )
      @processing = false
    catch error
      #correct the line number to account for all the pre-injected code
      if error.location?
        if @async
          lineOffset = -11
        else
          lineOffset = -15
        error.location.first_line = (error.location.first_line + lineOffset)
      logger.error( error )
      @deferred.reject( error )
      @processing = false
 
  _prepareScript:()=>
    #prepare the source for compiling : convert to coffeescript, inject dependencies etc
    @rawScript = @script 
    
    @script = """
    {Cube,ObjectBase} = geometryKernel
    
    #assembly = new THREE.Object3D()
    
    #clear log entries
    log = {}
    log.entries = []
    
    #clear class registry    
    classRegistry = {}
    
    #include script
    #{@script}

    """
    
    #Coffeescript redux
    ###
    parsed = CoffeeScript.parse(@script, {
     # optimise: false,
      raw: true
    })
    ast = CoffeeScript.compile(parsed,{bare:true})
    js = CoffeeScript.js(ast)
    @script = js
    #experimental
    parsed = CoffeeScript.parse(@rawScript, {raw: true})
    ast = CoffeeScript.compile(parsed,{bare:true})
    @rawScript = CoffeeScript.js(ast)
    ###
    
    #standard coffeescript
    {js, v3SourceMap, sourceMap} = CoffeeScript.compile(@script, {bare: true,sourceMap:true})
    @script = js 
    #console.log("js", js, "v3map", v3SourceMap, "map", sourceMap)
    logger.debug "JSIFIED script"
    logger.debug @script
  
  ###*
  * Make sure there have been ACTUAL changes to the code before doing the bulk of the work (ignore comment changes, whitespacing etc)
  ###
  _preOptimise:=>
    ast = esprima.parse(@script, { range: false, loc: false , comment:false})
    if (@_prevAst?)
      #TODO: remove stringification step if possible
      jsonAst1 = JSON.stringify(ast)
      jsonAst2 = JSON.stringify(@_prevAst)
      isDifferent = (jsonAst1 == jsonAst2)
      logger.info(" old ast is same as new ast", isDifferent)
      @reEvalutate = not isDifferent
    @_prevAst = ast
  
  ###*
  * inject meta data etc into relevant elements (classes) before evaluating
  * ###
  _upgradeScript:=>
    tracer = esmorph.Tracer.FunctionEntrance (fn) ->
      #console.log "tracer entry", fn
      if fn.name != "ctor"
        signature = """
          this.meta = {
            lineNumber: #{fn.line}, 
            range: [ #{fn.range[0]}, #{fn.range[1]}]
          }
          """
      else
        ""
  
    @script = esmorph.modify(@script, tracer)
    #console.log("Raw esmorph code", code)
    #code = '(function() {\n' + code + '\n}())'
    
    #add return statement
    #return results as an object for cleaness
    bla = """
    var result = {"rootAssembly":assembly,"partRegistry":classRegistry, "logEntries":log.entries}
    return result;"""
    @script = @script + bla
    
    logger.debug("Final code", @script)
  
  evaluateScript: (script, params) -> 
    #Parse the given coffeescad script in the UI thread (blocking but simple)
    workerscript = script
    if @debug
      workerscript += "//Debugging;\n"
      workerscript += "debugger;\n"
      
    #YYYUUUCK!!!
    assembly = new THREE.Object3D()
    
    f = new Function("geometryKernel","assembly", workerscript)
    result = f(shapesKernel,assembly)
    #{rootAssembly} = result
    {rootAssembly,partRegistry,logEntries} = result
    
    logger.debug "compile result"+ result
    #@callback(rootAssembly,partRegistry,logEntries)
    return rootAssembly
  
  ###* 
  *Experimental find transformation stack of each shape: not sure this should be here!!
  *
  ###
  _findShapeInstanceTransforms: ( shape )->
    
  
module.exports = Processor