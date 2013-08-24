'use strict'
Kernel = require("../src/kernel")

describe "Integration test", ->
  kernel = null
  
  beforeEach ->
      kernel = new Kernel()
      
  it 'can compile source code',->
    source = """ 
    cube = new Cube();
    
    assembly.add(cube);
    """
    kernel.compile(source)
