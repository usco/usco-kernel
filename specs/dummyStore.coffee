
class DummyStore
  loadFile:( uri )=>
    fs = require('fs')
    
    stats = fs.lstatSync(uri)
    #console.log("stats", stats)
    
    data = fs.readFileSync( uri, 'utf8' )
    #console.log("data",data)
    return data


module.exports = DummyStore