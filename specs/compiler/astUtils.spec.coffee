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
      testVar = "someTestThatShouldNotBeExported"
      console.log("error", error)
    
    fooInstance = new Foo(76)
    
    exports.someData = firstVar + " " + secondVar
    """
    source = CoffeeScript.compile(source, {bare: true})
    ast = astAnalyser.codeToAst( source )
    results = astAnalyser.analyseAST( ast )
    
    obsResult = results.rootElements.sort()
    expResult = ["firstVar", "secondVar", "Foo", "fooInstance"].sort()
    
    expect( obsResult ).toEqual( expResult )
    

  it 'can trace param impacts', ->
    source = """
    # Roller
    # if you want to use bearings change the dimensions 
    class Roller extends Part
      constructor:(options)->
        @defaults = {
          roller_outer: 12,
          roller_inner: 3,
          roller_thickness: 10
        }
        options = @injectOptions(@defaults,options)
        super options 
        o = new Cylinder({r:@roller_outer/2,h:@roller_thickness})
        i = new Cylinder({r:@roller_inner/2,h:@roller_thickness*2})
        o.subtract(i)
        o.color([0.4,0.4,0.4])
        @union(o)
  """
    source = CoffeeScript.compile(source, {bare: true})
    ast = astAnalyser.codeToAst( source )
    
    variableName = "roller_outer"
    
    #astAnalyser.traceVariableImpact:( variableName, null )
    #TODO: remove this: for testing
    ### 
    esgraph = require('esgraph')
    esprima = require('esprima')
    fs = require('fs')

    cfg = esgraph(esprima.parse(source, {range: true}))
    dot = esgraph.dot(cfg, {source: source})
    console.log "DOT",dot
    
    fs.writeFileSync( "AST_graph.dot", dot )
    #CMD line to generate graph : dot -Tpng -ooutput.png AST_graph.dot
    ###
    

