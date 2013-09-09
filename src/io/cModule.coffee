'use strict'

File = require './File'

###* 
* Coffeescad module : it is NOT a node.js module, althouth its purpose is similar, and a part of the code
* here is ported from node modules
###
class CModule extends File
  constructor:(name, content, parent)->
    super( name, content )
    @exports = {}
    
    @loaded = false
    @exports = {}
    
    @parent = null
    @children = []
    
    @_extensions = []
    
    @_extensions["coffee"] = ""
      
  
  include:(include)->
    console.log "include : #{include}"
    
  importGeom:( uri )->
    console.log "import geometry at #{uri}"
    
  compile:()->
    wrapped = @wrap(@content)
        
    f = new Function( wrapped )
    fn = f()
    
    fn( @exports, @include, @importGeom @, @name)
      
    #f = new Function(["module","assembly"], wrapper )
    #toto = f.apply(null, [module,assembly])
  
  
  eval:->
    
  
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