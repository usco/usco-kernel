logger = require("../../logger")
logger.level = "debug"

esprima = require "esprima"
estraverse = require "estraverse"


class ASTAnalyser
  constructor:->

  codeToAst:( source )->
    ast = esprima.parse(source, { range: false, loc: false , comment:false})
    return ast
  
  ###*
  * Determine if current node is an "include" call node
  * @param {Object} node the AST node to test
  * @return {boolean} true if node is an include node, false otherwise
  ### 
  isInclude: ( node )->
    c = node.callee
    return (c and node.type == 'CallExpression' and c.type == 'Identifier' and c.name == 'include')

  ###*
  * Determine if current node is an "isImportGeom" call node
  * @param {Object} node the AST node to test
  * @return {boolean} true if node is an isImportGeom node, false otherwise
  ###  
  isImportGeom: ( node )->
    c = node.callee
    return (c and node.type == 'CallExpression' and c.type == 'Identifier' and c.name == 'importGeom')
  
  ###*
  * Determine if current node is a "try catch" node
  * @param {Object} node the AST node to test
  * @return {boolean} true if node is an isImportGeom node, false otherwise
  ###  
  isTryCatch: ( node )->
    return (node.type == 'TryStatement')
  
  ###*
  * Determine if current node is a parameter definition node
  * @param {Object} node the AST node to test
  * @return {boolean} true if node is a parameter node, false otherwise
  ###  
  isParams: ( node )->
    #TODO: fix this 
    c = node.callee
    if c?
      name = c.name
    #console.log "NODE", node, "callee",c, "Cname", name, "type",node.type, "name", node.name
    return (c and node.type == 'VariableDeclaration' and c.type == 'Identifier' and c.name == 'params')
  
  ###*
  * Determine if current node is an instanciation
  * @param {Object} node the AST node to test
  * @return {boolean} true if node is a parameter node, false otherwise
  ###  
  isInstanciation:( node )->
    #what = null
    #if node.type == 'NewExpression'
    #  what = node.callee.name
    c = node.callee
    #console.log("pouet", node.type == 'NewExpression')
    return (c and node.type == 'NewExpression')
    ###
    "init": {
                        "type": "NewExpression",
                        "callee": {
                            "type": "Identifier",
                            "name": "Dummy"
                        },
                        "arguments": [
                            {
                                "type": "Literal",
                                "value": 25,
                                "raw": "25"
                            }
                        ]
                    } 
  
    ###
    
    
  ###*
  * Find any variable assignements inside a (try) catch block: this is used to eliminate variables such as "error"
  * from auto imports parsing
  * @param {Object} tryStatementNode a tryStatementNode
  * @return {List} a list of variable names that have been assigned inside 
  ###  
  findCatchVariables:( tryStatementNode ) ->
    innerVariables = []
    try
      h = tryStatementNode.handlers[0]
      expressions = h.body.body
      #console.log "expressions", h.body.body
      for node in expressions
        if node.type is "ExpressionStatement" and node.expression.type is "AssignmentExpression"
          varName = node.expression.left.name
          #console.log " VAR", varName
          innerVariables.push( varName )
    catch error
      logger.error(error)
  
    return innerVariables
      
  
  ###*
  * Traverse the AST , analyse and spit out the needed information
  * @param {Object} ast the esprima generated AST
  * @return {Object} 
  ### 
  analyseAST:( ast )=>
    
    traverse = (object,limit,level, visitor, path) =>
      #console.log "level",level, "limit", limit, "path",path
      #limit = limit or 2
      #level = level or 0
      #console.log "visitore", visitor
      if level < limit or limit == 0
        key = undefined
        child = undefined
        path = []  if typeof path is "undefined"
        visitor.call null, object, path, level
        subLevel = level+1
        for key of object
          if object.hasOwnProperty(key)
            child = object[key]
            traverse child, limit, subLevel, visitor, [object].concat(path)  if typeof child is "object" and child isnt null
    
    #get all the things we need from ast
    rootElements = []
    includes = []
    importGeoms = []
    params = [] #TODO: only one set of params is allowed, this needs to be changed
    
    
    #ALL of the level 0 (root level) items need to be added to the exports, if so inclined
    traverse ast,0,0, (node, path, level) =>
      name = undefined
      parent = undefined
      
      #console.log("level",level)
      
      if node.type is esprima.Syntax.VariableDeclaration and level is 2
        for dec in node.declarations
          decName = dec.id.name
          #console.log "ElementName", decName
          rootElements.push( decName )
      
      #eliminate anythin in try blocks
      if node.type is esprima.Syntax.TryStatement and level is 2
        variableInTryBlock = @findCatchVariables( node )
        rootElements = (item for item in rootElements when item not in variableInTryBlock) 
    
      if @isInclude( node )
        logger.debug("include",node.arguments[0].value)
        includes.push( node.arguments[0].value )
      
      if @isImportGeom( node )
        logger.debug("importGeom",node.arguments[0].value)
        importGeoms.push( node.arguments[0].value )
      
      if @isParams( node )
        logger.debug("params",node.arguments[0].value)
        params.push( node.arguments[0].value )
        
      if @isInstanciation( node )
        logger.debug("new instance of ",node.callee.name)
    
    logger.debug("found rootElements", rootElements)
    logger.debug("found includes",includes)
    logger.debug("found importGeoms",importGeoms)   
    logger.debug("found params",params)    
    
    return {rootElements:rootElements, includes:includes, importGeoms:importGeoms}


  ###*
  * TODO: find other name
  * this traces the impact of a variable on the rest of the code : ie if a variable is used in an expression, which is in turned used to compute
  * another variable we want to know that
  * @param {String} variableName, name of the variable to trace
  * @param {Object} rootNode the AST node to start at
  * @return {boolean}  ?????
  ### 
  traceVariableImpact:( variableName, rootNode )->
    #TODO: should it return a list / tree of nodes where it gets used, starting at initialization ????
    

module.exports = ASTAnalyser