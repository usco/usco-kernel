CoffeeScript =  require('coffee-script-redux')
Q = require("q")

shapesKernel = require '../shapes/api'


class Processor
  #processes a csg script
  construtor:()->
    @async = false
    
  processScript:(script, async=false, params)-> 
    @script = script
    @async = async
    @params = params  
    
    @deferred = Q.defer()    
    
    @generateAssembly()
    return @deferred.promise

    
  generateAssembly:() =>
    @processing = true
    try
      @_prepareScriptSync()
      rootAssembly = @evaluateScriptSync(@script, @params)
      console.log "gna", rootAssembly
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
    
      @deferred.reject( error )
      @processing = false
 
  _prepareScriptSync:()=>
    #prepare the source for compiling : convert to coffeescript, inject dependencies etc
    @script = """
{Cube}=geometryKernel

assembly = new THREE.Object3D()

#include script
#{@script}


#return results as an object for cleaness
result = {rootAssembly:assembly};
return result
    """
    
    #Coffeescript redux
    parsed = CoffeeScript.parse(@script, {
     # optimise: false,
      raw: true
    })
    ast = CoffeeScript.compile(parsed,{bare:true})
    js = CoffeeScript.js(ast)
    #@script = CoffeeScript.compile(@script, {bare: true})
    #console.log "JSIFIED script"
    #console.log js
    @script = js
  
  
  evaluateScriptSync: (script, params) -> 
    #Parse the given coffeescad script in the UI thread (blocking but simple)
    workerscript = script
    if @debug
      workerscript += "//Debugging;\n"
      workerscript += "debugger;\n"
    
    #YYYUUUCK!!!
    THREE = require( 'three' )
    rootAssembly = new THREE.Object3D()
    f = new Function("geometryKernel", workerscript)
    result = f(shapesKernel)
    {rootAssembly} = result
    
    console.log "compile result", result
    #@callback(rootAssembly,partRegistry,logEntries)
    return rootAssembly
    
module.exports = Processor