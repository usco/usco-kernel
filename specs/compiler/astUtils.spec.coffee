'use strict'
CoffeeScript =  require('coffee-script')
fs = require("fs")
path = require("path")

ASTAnalyser = require "../../src/compiler/astUtils"


describe "ASTAnalyser", ->
  astAnalyser = null
  
  beforeEach ->
    astAnalyser = new ASTAnalyser()
    
    
  it 'can get all rootLevel elements to be used for exports autoGeneration', ->
    source = """
    firstVar = 42
    secondVar = "someData"
    
    class Foo
      constructor:(amount)->
        @amount = amount
        @attrib = {"bar":"tipsy","vodka":"ouch"}
    
    try
      throw new Error("Dreadfull I tell you")
    catch error
      console.log("error", error)
    
    fooInstance = new Foo(76)
    
    exports.someData = firstVar + " " + secondVar
    """
    source = CoffeeScript.compile(source, {bare: true})
    console.log "source", source
    ast = astAnalyser.codeToAst( source )
    results = astAnalyser.analyseAST( ast )
    
    obsResult = results.rootElements.sort()
    expResult = ["firstVar", "secondVar", "Foo", "fooInstance"].sort()
    
    expect( obsResult ).toEqual( expResult )
    
    
