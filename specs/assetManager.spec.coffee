'use strict'
AssetManager = require("../src/assetManager")
THREE = require( 'three' )
STLParser = require "./STLParser"
AMFParser = require "./AMFParser"

DummyStore = require "./dummyStore"

describe "AssetManager", ->
  assetManager = null
  stores = []
  
  beforeEach ->
    stores["dummy"] = new DummyStore()
    assetManager = new AssetManager( stores )


  it 'can cache resources',->
    storeName = "dummy"
    
    assetManager.addParser("stl", STLParser)
    
    stlFileName = "specs/cube.stl"
    
    expect(assetManager.assetCache).toEqual({})
    loadedResource = assetManager.loadResource( storeName, stlFileName )
    expect(assetManager.assetCache).toEqual({"specs/cube.stl":loadedResource})
    loadedResource = assetManager.loadResource( storeName, stlFileName )
    expect(assetManager.assetCache).toEqual({"specs/cube.stl":loadedResource})


### 
  it 'can handle various file types via settable parsers',->
    storeName = "dummy"
    
    assetManager.addParser("stl", STLParser)
    assetManager.addParser("amf", AMFParser)
    
    stlFileName = "specs/cube.stl"
    amfFileName = "specs/Constellation.amf"
    
    #loadedResource = assetManager.loadResource( storeName, amfFileName )
    loadedResource = assetManager.loadResource( storeName, stlFileName )
    expect(loadedResource).toEqual("toto")
###  
