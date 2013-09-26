### 
Processor = require "../../src/compiler/processor"
  
describe "Processor", ->
  processor= null
  stores = []
  
  beforeEach ->
    processor = new Processor()
  
  
  it 'generates an assembly of shapes from code', (done)->
    source = "assembly.add( new Cube() )"
    
    source = """ 
    class Something extends ObjectBase
      constructor:(options)->
        super(options)
        @toto= 25
        
    smthg = new Something()
    assembly.add( smthg )
    
    """
     
    processor.processScript( source ).then ( rootAssembly) =>
      #console.log "processor result", rootAssembly
      done()
    .catch ( error ) =>
      console.log( "processor error", error )
      done()
  , 400
  
  it 'avoid recompiling on trivial changes (comments, whitespace', (done)->
    source = "assembly.add( new Cube() )"
    console.log "h"
    processor.processScript( source ).then ( rootAssembly) =>
      expect( processor.reEvalutate ).toBe( true )
      processor.processScript( source )
      expect( processor.reEvalutate ).toBe( false )
      done()
###