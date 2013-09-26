'use strict'
### 
Kernel = require "../src/kernel"


#Full tests : compile & export
describe "Integration test", ->
  kernel = null
  
  beforeEach: ->
    kernel = new Kernel()
      
  it 'can compile a full project in a given folder, export it to a given format', ->
    
    #kernel.compile(source)
###