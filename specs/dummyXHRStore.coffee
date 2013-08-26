#Q = require("q")

class DummyXHRStore
  loadFile:( uri , onLoad, onProgress, onError )=>
    request = new XMLHttpRequest()
    
    if ( onLoad is not undefined )
      console.log "gne"
      request.addEventListener( 'load', ( event )->

        onLoad( event.target.responseText );
        scope.manager.itemEnd( url );

      , false )
    
    request.open( 'GET', url, true );
    request.send( null );
    

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

module.exports = DummyXHRStore