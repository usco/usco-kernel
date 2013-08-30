Processor = require "../../src/compiler/processor"
  
checkDeferred=(df,fn) ->
  callback = jasmine.createSpy()
  df.then(callback)
  waitsFor -> callback.callCount > 0
  
  runs -> 
    fn.apply @,callback.mostRecentCall.args if fn


describe "Processor", ->
  processor= null
  
  beforeEach ->
    processor = new Processor()
    
  it 'generates an assembly of shapes from code', (done)->
    source = "assembly.add( new Cube() )"
     
    processor.processScript( source ).done ( rootAssembly) =>
      console.log "processor result", rootAssembly
      done()
    ### 
    .catch ( error ) =>
      console.log( "processor error", error )
      done()### 
  , 400
 