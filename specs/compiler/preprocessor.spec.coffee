'use strict'

#PreProcessor = require "../../src/compiler/preprocessor"
AssetManager = require "../../src/assetManager"
PreProcessor = require "../../src/compiler/preprocessor"
File = require "../../src/io/file"

DummyStore = require "../dummyStore"
DummyXHRStore = require "../dummyXHRStore"
  

describe "PreProcessor", ->
  stores = []
  project = null
  
  assetManager = null
  preprocessor= null
  
  beforeEach ->
    stores["dummy"] = new DummyStore()
    stores["xhr"] = new DummyXHRStore()
    
    #project = new Project
    #  name:"TestProject"
    assetManager = new AssetManager( stores )
    preprocessor = new PreProcessor( assetManager )
  
  it 'handle include statements',(done)-> #seriously?
    #testFile = new File( "testFile.coffee", """include ("config.coffee")""")
    testFile = new File( "testFile.coffee", """include ("dummy:specs/data/test.coffee")""")
  
    preprocessor.process( testFile ).done ( bla ) =>
      console.log "bla",bla
      done()
    
  ###  
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
  

  it 'throws an error if there is no correctly named main file',->
    project.addFile
      name:"NotTheRightName.coffee"
      content:""""""
    expect(()-> (preprocessor.process(project))).toThrow("Missing main file (needs to have the same name as the project containing it)")
  
  
  it 'can emulate coffeescript function syntax (with or without parens) (as it is a "pseudo method") for includes',->
    project.addFile
      name:"TestProject.coffee"
      content:"""include ("config.coffee")"""
    project.addFile
      name:"config.coffee"
      content:"""testVariable = 42"""  
    
    expPreProcessedSource = """
    
    testVariable = 42
    
    """
    checkDeferred $.when(preprocessor.process(project)), (obsPreprocessedSource) =>
      expect(obsPreprocessedSource).toBe(expPreProcessedSource)
    
  it 'can process file includes from the current project (simple)',->
    project.addFile
      name:"TestProject.coffee"
      content:"""include ("config.coffee")
      mainVariable = testVariable+2
      """
    project.addFile
      name:"config.coffee"
      content:"""testVariable = 42"""
    
    expPreProcessedSource = """
    
    testVariable = 42

    mainVariable = testVariable+2
    """
    checkDeferred $.when(preprocessor.process(project)), (obsPreprocessedSource) =>
      expect(obsPreprocessedSource).toBe(expPreProcessedSource)
        
  it 'can process file includes from the current project (complex)',->
    project.addFile
      name:"TestProject.coffee"
      content:"""include "config.coffee"
      include "file1.coffee"
      include "file2.coffee"
      include "file3.coffee"
      mainVariable = testVariable+2
      """
    project.addFile
      name:"config.coffee"
      content:"""testVariable = 42"""
    
    project.addFile
      name:"file1.coffee"
      content:"""
      include "config.coffee"
      a=1"""
    project.addFile
      name:"file2.coffee"
      content:"""
      include "config.coffee"
      b=2"""
    project.addFile
      name:"file3.coffee"
      content:"""
      include "config.coffee"
      c=3"""
    
    expPreProcessedSource = """
    
    testVariable = 42
    
    a=1
    
    b=2
    
    c=3

    mainVariable = testVariable+2
    """
    checkDeferred $.when(preprocessor.process(project)), (obsPreprocessedSource) =>
      expect(obsPreprocessedSource).toBe(expPreProcessedSource)
    
  it 'can process file includes from another project (browserStore) single level',->
    project.addFile
      name:"TestProject.coffee"
      content:"""include ("config.coffee")
      include ("browser:OtherProject/OtherProject.coffee")
      mainVariable = testVariable+2
      """
    project.addFile
      name:"config.coffee"
      content:"""testVariable = 42"""
    
    otherProject = new Project({name:"OtherProject"})
    otherProject.addFile
      name:"OtherProject.coffee"
      content:"""
      otherProjectVariable = 666
      """
    browserStore = new BrowserStore({storeURI:"testStore"})
    browserStore.saveProject(otherProject)
    
    expPreProcessedSource = """
    
    testVariable = 42
    
    otherProjectVariable = 666
    
    mainVariable = testVariable+2
    """
    
    checkDeferred $.when(preprocessor.process(project)), (obsPreprocessedSource) =>
      expect(obsPreprocessedSource).toBe(expPreProcessedSource)
    
    
  
  it 'can process file includes from another project (browserStore) multi level',->
    project.addFile
      name:"TestProject.coffee"
      content:"""include ("config.coffee")
      include ("browser:OtherProject/OtherProject.coffee")
      mainVariable = testVariable+2
      """
    project.addFile
      name:"config.coffee"
      content:"""testVariable = 42"""
    
    otherProject = new Project({name:"OtherProject"})
    otherProject.addFile
      name:"OtherProject.coffee"
      content:"""
      otherProjectVariable = 666
      include("config.coffee")
      """
    otherProject.addFile
      name:"config.coffee"
      content:"""secondLevelIncludeVar = 24"""
    
    browserStore = new BrowserStore({storeURI:"testStore"})
    browserStore.saveProject(otherProject)
    
    expPreProcessedSource = """
    
    testVariable = 42
    
    otherProjectVariable = 666
    secondLevelIncludeVar = 24
    
    
    
    mainVariable = testVariable+2
    """
    
    checkDeferred $.when(preprocessor.process(project)), (obsPreprocessedSource) =>
      expect(obsPreprocessedSource).toBe(expPreProcessedSource)

  it 'can process project includes',->
    project.addFile
      name:"TestProject.coffee"
      content:"""include ("browser:OtherProject")
      mainVariable = testVariable+2
      """
    
    browserStore = new BrowserStore({storeURI:"testStore"})
    
    otherProject = new Project({name:"OtherProject"})
    otherProject.addFile
      name:"OtherProject.coffee"
      content:"""
      class Test extends Part
        constructor:(options)->
          super options
          @union( new Cube({size:200}))
          
      mainVariable = testVariable+2
      """
    browserStore.saveProject(otherProject)
    
    expPreProcessedSource = """
    
    OtherProject = {"OtherProject.coffee":{}}
    
    mainVariable = testVariable+2
    """
    
    obsPreprocessedSource = preprocessor.process(project)
    expect(obsPreprocessedSource).toBe(expPreProcessedSource)
###
  

