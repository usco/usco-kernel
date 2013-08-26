Q = require("q")


class DummyStore
  loadFile:( uri )=>
    deferred = Q.defer()
    
    fs = require('fs')
    
    stats = fs.lstatSync(uri)
    #console.log("stats", stats)
    
    data = fs.readFileSync( uri, 'utf8' )
    #console.log("data",data)
    deferred.resolve(data)
    
    return deferred.promise


module.exports = DummyStore