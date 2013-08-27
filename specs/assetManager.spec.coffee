'use strict'
AssetManager = require("../src/assetManager")
THREE = require( 'three' )
STLParser = require "./STLParser"
AMFParser = require "./AMFParser"

DummyStore = require "./dummyStore"
DummyXHRStore = require "./dummyXHRStore"

checkDeferred=(df,fn) ->
    callback = jasmine.createSpy()
    df.then(callback)
    waitsFor -> callback.callCount > 0
    
    runs -> 
      fn.apply @,callback.mostRecentCall.args if fn

describe "AssetManager", ->
  assetManager = null
  stores = []
  
  beforeEach ->
    stores["dummy"] = new DummyStore()
    stores["xhr"] = new DummyXHRStore()
    assetManager = new AssetManager( stores )
  
  it 'should fail to load resources gracefully',(done)->
    assetManager.addParser("stl", STLParser)
    
    fileUri = "dummy:specs/femur.stl"
    assetManager.loadResource( fileUri ).catch ( error ) =>
      expect(error).toEqual("specs/femur.stl not found")
      done()
  , 400
  
  it 'can load resources from different stores',(done)->
    assetManager.addParser("stl", STLParser)
    
    fileUri = "dummy:specs/cube.stl"
    assetManager.loadResource( fileUri ).done ( loadedResource ) =>
      expect( loadedResource ).not.toEqual(null)

    fileUri = "https://raw.github.com/kaosat-dev/repBug/master/cad/stl/femur.stl"
    assetManager.loadResource( fileUri ).done ( loadedResource ) =>
      expect( loadedResource ).not.toEqual(null)
      done()
    
    #fileUri = "/home/mmoisset/specs/cube.stl"
    #fileUri = "specs/cube.stl"

  it 'caches resources by default',(done)->
    assetManager.addParser("stl", STLParser)
    stlFileName = "dummy:specs/cube.stl"
    
    expect(assetManager.assetCache).toEqual({})
    
    assetManager.loadResource( stlFileName ).done (loadedResource) =>
      expect( assetManager.assetCache ).toEqual({"specs/cube.stl":loadedResource})
      done()

  it 'does not cache transient resources',(done)->
    assetManager.addParser("stl", STLParser)
    stlFileName = "dummy:specs/cube.stl"
    
    expect(assetManager.assetCache).toEqual({})
    
    assetManager.loadResource( stlFileName, true ).done (loadedResource) =>
      expect(assetManager.assetCache).toEqual({})
      done()    
  
  it 'can load source files (no parsing, raw text)',(done)->
    fileName = "dummy:specs/test.coffee"
    expSource = """assembly.add( new Cube() )"""
    assetManager.loadResource( fileName, true ).done (loadedResource) =>
      expect(loadedResource).toEqual(expSource)
      done()
    
###
  it 'can handle various file types via settable parsers',(done)->
    storeName = "dummy"
    
    assetManager.addParser("stl", STLParser)
    assetManager.addParser("amf", AMFParser)
    
    stlFileName = "dummy:specs/cube.stl"
    amfFileName = "dummy:specs/Constellation.amf"
    
    assetManager.loadResource( stlFileName, true ).done (loadedResource) =>
      expect(loadedResource).toEqual({})
    
    assetManager.loadResource( amfFileName, true ).done (loadedResource) =>
      expect(loadedResource).toEqual({})
      done()

    

  it 'bla', (done)->
    Q = require("q")
    bla = new DummyXHRStore()
    fileUri = "https://raw.github.com/kaosat-dev/repBug/master/cad/stl/femur.stl"
    #fileUri = "http://www.google.com"
    
    bla.loadFile( fileUri ).done ( loadedResource ) =>
      console.log("prout loadedResource")#,loadedResource)
      expect( loadedResource ).not.toEqual(null)
      done()

    checkDeferred Q.when(bla.loadFile( fileUri )), (loadedResource) =>
      console.log("prout loadedResource",loadedResource)
      expect( loadedResource ).not.toEqual(null)
      
  
###  
