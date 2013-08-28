###* 
* Find any parameters given to the script
###
parseParams = ( source )=>
  source = source or ""
  #params : hash of params -> defaults
  params = {}
  rawParams = {}
  
  buf = ""
  openBrackets = 0
  closeBrackets = 0
  startMark = null
  endMark = null
  for char,index in source
    buf+=char
    
    if buf.indexOf("params=") != -1 or buf.indexOf("params =") != -1#"para" in buf
      console.log "found params at",index
      startMark = index
      buf = ""
    
    if startMark != null
      if buf.indexOf("{") != -1 
        openBrackets += 1
        buf = ""
      if buf.indexOf("}") != -1 
        closeBrackets += 1
        buf = ""
      if openBrackets == closeBrackets and openBrackets != 0
        endMark = index
        break
  
  if startMark != null
    paramsSourceBlock = "params " + source.slice(startMark,endMark+1)
    params = eval(paramsSourceBlock)
    
    results = {}
    for param in params.fields
      results[param.name]=param.default
    source = source.replace(paramsSourceBlock, "")
    
    params = results
    rawParams = eval(paramsSourceBlock)
   
  return {source:source, params:params, rawParams:rawParams}

module.exports = parseParams