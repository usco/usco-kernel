
  var Compiler, PreProcessor, Processor, merge, utils;
  utils = require('../utils');
  merge = utils.merge;
  PreProcessor = require("./preprocessor");
  Processor = require("./processor");
  Compiler = (function() {
    function Compiler(options) {
      this._generateBomEntries = __bind(this._generateBomEntries, this);
      this._parseLogEntries = __bind(this._parseLogEntries, this);
      this._processScript = __bind(this._processScript, this);
      this.compile = __bind(this.compile, this);
      var defaults;
      defaults = {
        project: null,
        backgroundProcessing: false
      };
      options = merge(defaults, options);
      this.project = options.project, this.backgroundProcessing = options.backgroundProcessing;
      this.preProcessor = new PreProcessor();
      this.processor = new Processor();
      this.compileResultData = {};
      this.compileResultData["logEntries"] = null;
      this.compileResultData["errors"] = null;
    }

    Compiler.prototype.compile = function(options) {
      var defaults,
        _this = this;
      defaults = {
        backgroundProcessing: false
      };
      options = merge(defaults, options);
      this.backgroundProcessing = options.backgroundProcessing;
      this.compileResultData["logEntries"] = [];
      this.compileResultData["errors"] = [];
      console.log("compiling");
      this._compileStartTime = new Date().getTime();
      this.preProcessor.process(this.project, false).done(function() {
        _this.project.trigger("compiled:params", _this.compileResultData);
      }).fail(function(errors) {
        if (!(errors instanceof Array)) {
          errors = [errors];
        }
        _this.compileResultData["errors"] = errors;
        return _this.project.trigger("compile:error", _this.compileResultData);
      });
      return this.preProcessor.process(this.project, false).pipe(this._processScript).done(function() {
        _this.project.trigger("compiled", _this.compileResultData);
      }).fail(function(errors) {
        if (!(errors instanceof Array)) {
          errors = [errors];
        }
        _this.compileResultData["errors"] = errors;
        return _this.project.trigger("compile:error", _this.compileResultData);
      });
    };

    Compiler.prototype._processScript = function(source) {
      var deferred, error, params,
        _this = this;
      deferred = $.Deferred();
      if (this.project === null) {
        error = new Error("No project given to the compiler");
        deferred.reject(error);
      }
      if (this.project.meta.modParams != null) {
        params = this.project.meta.modParams;
      } else {
        params = this.project.meta.params;
      }
      console.log("injecting params", this.project);
      console.log("injecting params", params);
      this.processor.processScript(source, this.backgroundProcessing, params, function(rootAssembly, partRegistry, logEntries, error) {
        _this.compileResultData["logEntries"] = logEntries || [];
        if (error != null) {
          return deferred.reject([error]);
        } else {
          _this._generateBomEntries(rootAssembly, partRegistry);
          _this.project.rootAssembly = rootAssembly;
          _this._compileEndTime = new Date().getTime();
          console.log("Csg computation time: " + (_this._compileEndTime - _this._compileStartTime));
          return deferred.resolve();
        }
      });
      return deferred;
    };

    Compiler.prototype._parseLogEntries = function(logEntries) {
      var result;
      result = [];
      return result;
    };

    Compiler.prototype._generateBomEntries = function(rootAssembly, partRegistry) {
      var getChildrenData, name, param, params, partInstances, parts, quantity, variantName,
        _this = this;
      partInstances = new Backbone.Collection();
      parts = {};
      getChildrenData = function(assembly) {
        var index, isInAssembly, params, part, partClassEntry, partClassName, partIndex, _ref, _ref1, _results;
        _ref = assembly.children;
        _results = [];
        for (index in _ref) {
          part = _ref[index];
          if (part.realClassName != null) {
            partClassName = part.realClassName;
          } else {
            partClassName = part.__proto__.constructor.name;
          }
          if (partClassName in partRegistry) {
            partClassEntry = partRegistry[partClassName];
            isInAssembly = false;
            params = "";
            for (params in partClassEntry) {
              index = partClassEntry[params];
              if (_ref1 = part.uid, __indexOf.call(partClassEntry[params].uids, _ref1) >= 0) {
                isInAssembly = true;
                partIndex = index;
                break;
              }
            }
            if (isInAssembly) {
              if (!(partClassName in parts)) {
                parts[partClassName] = {};
              }
              if (!(params in parts[partClassName])) {
                parts[partClassName][params] = 0;
              }
              parts[partClassName][params] += 1;
            }
          }
          _results.push(getChildrenData(part));
        }
        return _results;
      };
      getChildrenData(rootAssembly);
      for (name in parts) {
        params = parts[name];
        for (param in params) {
          quantity = params[param];
          variantName = "Default";
          if (param !== "") {
            variantName = "";
          }
          partInstances.add({
            name: name,
            variant: variantName,
            params: param,
            quantity: quantity,
            manufactured: true,
            included: true
          });
        }
      }
      return this.project.bom = partInstances;
    };
