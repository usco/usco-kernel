'use strict'
Geometry2d = require("../../src/geometry/2d/geometry2d")
Geometry3d = require("../../src/geometry/3d/geometry3d")

describe "basic geometry classes", ->
  
  it 'works', ->
    #duuuh !!
    geom2d = new Geometry2d()
    geom3d = new Geometry3d()
    
    console.log("2d",geom2d)
    console.log("3d",geom3d)
    
    THREE = require('three')
    console.log geom2d.holes
    
    kernel = kernel2 = "42"
    expect(kernel).toEqual(kernel2)
    
###
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


  
