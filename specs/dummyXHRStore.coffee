Q = require("q")
XMLHttpRequest = require("w3c-xmlhttprequest").XMLHttpRequest

class DummyXHRStore
  loadFile:( uri )=>
    request = new XMLHttpRequest()
    deferred = Q.defer()
    #console.log("attempting to load",uri)
    
    request.open( 'GET', uri, true );
    
    onLoad= ( event )=>
      #console.log "xhr success", event.target.responseText
      deferred.resolve(event.target.responseText);
    
    onProgress= ( event )=>
      if (event.lengthComputable)
        percentComplete = (event.loaded/event.total)*100
        console.log "percent", percentComplete
    
    onError= ( event )=>
      console.log("errorblah", event)
      deferred.reject(event);
    
    onXhrChange= (event)=>
      #console.log "xhr ready state",request.readyState
      #if (request.readyState is 4)
      #  console.log "pouet"
      #  console.log("Complete.\nBody length: " + request.responseText.length);
      #  console.log("Body:\n" + request.responseText);
    
    request.addEventListener 'load', onLoad, false
    request.addEventListener 'loadend', onLoad, false
    request.addEventListener 'progress', onProgress, false
    request.addEventListener 'error', onError, false
    request.addEventListener 'readystatechange', onXhrChange, false
    
    request.send()
    
    return deferred.promise;    
    
    
    
module.exports = DummyXHRStore
### 
    if ( onLoad !== undefined ) {

      request.addEventListener( 'load', function ( event ) {

        onLoad( event.target.responseText );
        scope.manager.itemEnd( url );

      }, false );

    }

    if ( onProgress !== undefined ) {

      request.addEventListener( 'progress', function ( event ) {

        onProgress( event );

      }, false );

    }

    if ( onError !== undefined ) {

      request.addEventListener( 'error', function ( event ) {

        onError( event );

      }, false );

    }

    if ( this.crossOrigin !== undefined ) request.crossOrigin = this.crossOrigin;

    request.open( 'GET', url, true );
    request.send( null );

    scope.manager.itemStart( url );

  },

  setCrossOrigin: function ( value ) {

    this.crossOrigin = value;

  }

};
###

