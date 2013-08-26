'use strict'
AssetManager = require("../src/assetManager")
THREE = require( 'three' )
STLParser = require "./STLParser"
AMFParser = require "./AMFParser"

DummyStore = require "./dummyStore"
DummyXHRStore = require "./dummyXHRStore"


describe "AssetManager", ->
  assetManager = null
  stores = []
  
  beforeEach ->
    stores["dummy"] = new DummyStore()
    assetManager = new AssetManager( stores )

  it 'caches resources by default',->
    assetManager.addParser("stl", STLParser)
    stlFileName = "dummy:specs/cube.stl"
    
    expect(assetManager.assetCache).toEqual({})
    loadedResource = assetManager.loadResource( stlFileName )
    expect(assetManager.assetCache).toEqual({"specs/cube.stl":loadedResource})
    loadedResource = assetManager.loadResource( stlFileName )
    expect(assetManager.assetCache).toEqual({"specs/cube.stl":loadedResource})

  it 'does not cache transient resources',->
    assetManager.addParser("stl", STLParser)
    stlFileName = "dummy:specs/cube.stl"
    
    expect(assetManager.assetCache).toEqual({})
    loadedResource = assetManager.loadResource( stlFileName, true )
    expect(assetManager.assetCache).toEqual({})
  
  it 'can handle different stores',->
    assetManager.addParser("stl", STLParser)
    #assetManager.stores["XHR"] = new DummyXHRStore()
    
    fileUri = "dummy:specs/cube.stl"
    #fileUri = "/home/mmoisset/specs/cube.stl"
    #fileUri = "specs/cube.stl"
    #fileUri = "https://github.com/kaosat-dev/repBug/blob/master/cad/stl/femur.stl"
    assetManager.loadResource( fileUri )

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
