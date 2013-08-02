
  var CoffeeScript, Processor, geometryKernel;

  CoffeeScript = require('CoffeeScript');
  geometryKernel = require('./geometry/api');

  Processor = (function() {
    function Processor() {
      this._prepareScriptSync = __bind(this._prepareScriptSync, this);
      this.rebuildSolid = __bind(this.rebuildSolid, this);
    }

    Processor.prototype.construtor = function() {
      this.async = false;
      this.debug = false;
    };

    Processor.prototype.processScript = function(script, async, params, callback) {
      if (async == null) {
        async = false;
      }
      this.script = script;
      this.async = async;
      this.params = params;
      this.callback = callback;
      return this.rebuildSolid();
    };

    Processor.prototype.rebuildSolid = function() {
      var error, lineOffset;
      this.processing = true;
      try {
        this._prepareScriptSync();
        this.parseScriptSync(this.script, this.params);
        return this.processing = false;
      } catch (_error) {
        error = _error;
        if (error.location != null) {
          if (this.async) {
            lineOffset = -11;
          } else {
            lineOffset = -15;
          }
          error.location.first_line = error.location.first_line + lineOffset;
        }
        this.callback(null, null, null, error);
        return this.processing = false;
      }
    };

    Processor.prototype._prepareScriptSync = function() {
      this.script = "{ObjectBase, Cube, Sphere, Cylinder, Circle, Rectangle, Text}=geometryKernel\n\nassembly = new THREE.Object3D()\n\n\n#clear log entries\nlog = {}\nlog.entries = []\n#clear rootAssembly\n#rootAssembly.clear()\n\nclassRegistry = {}\n\n#include script\n" + this.script + "\n\nrootAssembly = assembly\n\n#return results as an object for cleaness\nreturn result = {\"rootAssembly\":rootAssembly,\"partRegistry\":classRegistry, \"logEntries\":log.entries}\n";
      return this.script = CoffeeScript.compile(this.script, {
        bare: true
      });
    };

    Processor.prototype.parseScriptSync = function(script, params) {
      var f, logEntries, partRegistry, result, rootAssembly, workerscript;
      workerscript = script;
      if (this.debug) {
        workerscript += "//Debugging;\n";
        workerscript += "debugger;\n";
      }
      /* 
      partRegistry = {}
      logEntries = []
      
      f = new Function("partRegistry", "logEntries","csg", "params", workerscript)
      result = f(partRegistry,logEntries, csg, params)
      {rootAssembly,partRegistry,logEntries} = result
      console.log "RootAssembly", rootAssembly
      @_convertResultsTo3dSolid(rootAssembly)
      */

      rootAssembly = new THREE.Object3D();
      f = new Function("geometryKernel", workerscript);
      result = f(geometryKernel);
      rootAssembly = result.rootAssembly, partRegistry = result.partRegistry, logEntries = result.logEntries;
      console.log("compile result", result);
      return this.callback(rootAssembly, partRegistry, logEntries);
    };

	module.exports.Processor = Processor;
