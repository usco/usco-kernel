'use strict'

AssetManager = require "../../src/assetManager"
CModule = require "../../src/io/cModule"
File = require "../../src/io/file"

DummyStore = require "../dummyStore"
DummyXHRStore = require "../dummyXHRStore"
STLParser = require "../STLParser"  

describe "CModule", ->
  stores = []
  assetManager = null
  
  
  beforeEach ->
    stores["dummy"] = new DummyStore()
    stores["xhr"] = new DummyXHRStore()
    
    assetManager = new AssetManager( stores )
    assetManager.addParser("stl", STLParser)
  
  
  it 'handles all necessary pre-processing',(done)->
    
    #source = """include("dummy:specs/data/test.coffee")"""
    source = "variable = 42"
    source = """variable = 42
method= (param)->
  console.log("param",param);

class Dummy
  constructor:->
    @myVar = 42
    tmpVar = "my tailor is not so rich"

dummy = new Dummy()
    """
    source = """
    importGeom("dummy:specs/data/cube.stl")
    include("dummy:specs/data/test.coffee")
    """
    source = """
params 
include("dummy:specs/data/test.coffee")

variable = 42
method= (param)->
  console.log("param",param);

class Dummy
  constructor:->
    @myVar = 42
    tmpVar = "my tailor is not so rich"
    subGeom = importGeom("dummy:specs/data/cube.stl")
    subGeom2 = importGeom("dummy:specs/data/cube.stl")

dummy = new Dummy()
    """
    module = new CModule("testFile.Coffe", source)
    module.assetManager = assetManager #dependency injection, a bit weird ass : TODO: creating modules might be better done by factory that injects this??
    module.doAll()
    
    done()
    ### 
    preprocessor.process( source )
    .then ( bla ) =>
      console.log "bla",bla
      done()
    .fail (error) =>
      expect(false).toBeTruthy error.message
      done()
    ###
