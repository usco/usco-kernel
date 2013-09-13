Q = require("q")
http = require('https')
fs = require("fs")
path = require("path")
#mocking http requrest via  with https://github.com/flatiron/nock
nock = require("nock")

mockData = path.resolve("./specs/data/femur.stl")
nock.disableNetConnect()
nock("https://raw.github.com").get('/kaosat-dev/repBug/master/cad/stl/femur.stl')
.times(4)
.reply(200,fs.readFileSync(mockData))


#TODO: handle progress , errors
class DummyXHRStore
  
  loadFile:( uri )=>
    deferred = Q.defer()
   
    onLoad= ( res )=>
      final = ''
      #console.log "xhr success", event.target.responseText[0]+ event.target.responseText[1]+event.target.responseText[2]+event.target.responseText[3]
      res.on('data',(data)->
        final += data
      )
      
      res.on('end',()->
        #console.log "result", final
        deferred.resolve( final )
      )
    
    req = http.get(uri, onLoad)
    return deferred.promise

nock.enableNetConnect()    
    
module.exports = DummyXHRStore


