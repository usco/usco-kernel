'use strict'
AssetManager = require("../src/assetManager")


describe "AssetManager", ->
  assetManager = null
  stores = []
  
  beforeEach ->
    #stores.push
    assetManager = new AssetManager( stores )
  
  ### 
  it 'throws an error if there is no correctly named main file',->
    project.addFile
      name:"NotTheRightName.coffee"
      content:""""""
    expect(()-> (preprocessor.process(project))).toThrow("Missing main file (needs to have the same name as the project containing it)")
  ###


  
