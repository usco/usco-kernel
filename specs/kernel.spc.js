require.paths.unshift( '../../..' )
  
PreProcessor = require "src/compiler/preprocessor"
Project = require "src/compiler/preprocessor"
#BrowserStore = require "stores/browser/browserStore"
  
'use strict';


describe("HelloWorld", function() {
    it("hello() should say hello when called", function() {
        expect(HelloWorld.sayHello()).toEqual("hi world");
    });
});




  
