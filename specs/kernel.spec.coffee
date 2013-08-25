###'use strict'
Kernel = require("../src/kernel")


describe "Kernel", ->
  
  beforeEach ->
    #  kernel = new Kernel()
  
    

  it 'throws an error if there is no correctly named main file',->
    project.addFile
      name:"NotTheRightName.coffee"
      content:""""""
    expect(()-> (preprocessor.process(project))).toThrow("Missing main file (needs to have the same name as the project containing it)")

 
  it 'can check for circular dependency issues and raise an exception',->
    project.addFile
      name:"TestProject.coffee"
      content:"""include ("config.coffee")"""
    project.addFile
      name:"config.coffee"
      content:"""include ("someOtherFile.coffee")"""
    project.addFile
      name:"someOtherFile.coffee"
      content:"""include ("TestProject.coffee")"""
      
    expect(()-> (preprocessor.process(project))).toThrow("Circular dependency detected from someOtherFile.coffee to TestProject.coffee")
###


  
