'use strict'

File = require './File'

###* 
* Coffeescad module : it is NOT a node.js module, althouth its purpose is similar
###
class CModule extends File
  constructor:(name, content)->
    super( name, content )
    @exports = {}
    @fileName = ""
    @content = ""
    @loaded = false
    @exports = {}
    
    @parent = null
    @children = []
  
  include:(include)->
    console.log "include : #{include}"
    
  importGeom:( uri )->
    console.log "import geometry at #{uri}"
    
  compile:()->
    wrapped = @wrap(@content)
        
    f = new Function( wrapped )
    fn = f()
    
    fn( @exports, @include, @importGeom @, @fileName)
      
    #f = new Function(["module","assembly"], wrapper )
    #toto = f.apply(null, [module,assembly])
   
  wrap:(script)->
    wrapped = """
    return (function ( exports, include, module, __filename)
    {
      #{script}
      console.log("exports",exports, "module",module);
     });
    """
    return wrapped