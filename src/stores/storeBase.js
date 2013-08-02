
  var utils = require('../utils');
  var merge = utils.merge;

module.exports = StoreBase;

    function StoreBase(options) {
      this._sourceFetchHandler = __bind(this._sourceFetchHandler, this);
      this._dispatchEvent = __bind(this._dispatchEvent, this);
      this.getThumbNail = __bind(this.getThumbNail, this);
      this.loadFile = __bind(this.loadFile, this);
      this.saveFile = __bind(this.saveFile, this);
      this.renameProject = __bind(this.renameProject, this);
      this.deleteProject = __bind(this.deleteProject, this);
      this.loadProject = __bind(this.loadProject, this);
      this.saveProject = __bind(this.saveProject, this);
      this.listDir = __bind(this.listDir, this);
      this.logout = __bind(this.logout, this);
      this.login = __bind(this.login, this);
      var defaults;
      defaults = {
        enabled: true,
        pubSubModule: null,
        name: "store",
        shortName: "",
        type: "",
        description: "",
        rootUri: "",
        loggedIn: true,
        isLoginRequired: false,
        isDataDumpAllowed: false,
        showPaths: false
      };
      options = merge(defaults, options);
      StoreBase.__super__.constructor.call(this, options);
      this.enabled = options.enabled, this.pubSubModule = options.pubSubModule, this.name = options.name, this.shortName = options.shortName, this.type = options.type, this.description = options.description, this.rootUri = options.rootUri, this.loggedIn = options.loggedIn, this.isLoginRequired = options.isLoginRequired;
      this.cachedProjectsList = [];
      this.cachedProjects = {};
      this.fs = require('./fsBase');
    }

    StoreBase.prototype.login = function() {
      return this.loggedIn = true;
    };

    StoreBase.prototype.logout = function() {
      return this.loggedIn = false;
    };

    StoreBase.prototype.setup = function() {
      if (this.pubSubModule != null) {
        if (this.isLoginRequired) {
          this.pubSubModule.on("" + this.type + ":login", this.login);
          return this.pubSubModule.on("" + this.type + ":logout", this.logout);
        }
      }
    };

    StoreBase.prototype.tearDown = function() {};

    StoreBase.prototype.listDir = function(uri) {};

    StoreBase.prototype.saveProject = function(project, path) {
      var projectUri, targetName;
      console.log("saving project to " + this.type);
      project.dataStore = this;
      project.addOrUpdateMetaFile();
      if (path != null) {
        projectUri = path;
        project.uri = projectUri;
        targetName = this.fs.basename(path);
        if (targetName !== project.name) {
          return project.name = targetName;
        }
      } else {
        return projectUri = project.uri;
      }
    };

    StoreBase.prototype.loadProject = function(projectUri, silent) {
      if (silent == null) {
        silent = false;
      }
    };

    StoreBase.prototype.deleteProject = function(projectName) {};

    StoreBase.prototype.renameProject = function(oldName, newName) {};

    StoreBase.prototype.saveFile = function(file, uri) {};

    StoreBase.prototype.loadFile = function(uri) {};

    /*-------------Helpers ----------------------------*/


    StoreBase.prototype.getThumbNail = function(projectName) {};

    StoreBase.prototype.spaceUsage = function() {
      return {
        total: 0,
        used: 0,
        remaining: 0,
        usedPercent: 0
      };
    };

    /*--------------Private methods---------------------*/


    StoreBase.prototype._dispatchEvent = function(eventName, data) {
      if (this.pubSubModule != null) {
        return this.pubSubModule.trigger(eventName, data);
      } else {
        return console.log("no pubsub system specified, cannot dispatch event");
      }
    };

    StoreBase.prototype._sourceFetchHandler = function(_arg) {
      var file, getContent, index, namespaced, path, project, projectName, result, store, _ref, _ref1,
        _this = this;
      store = _arg[0], projectName = _arg[1], path = _arg[2];
      if (store !== this.storeShortName) {
        throw new Error("Bad store name specified");
      }
      console.log("handler recieved " + store + "/" + projectName + "/" + path);
      result = "";
      if ((projectName == null) && (path != null)) {
        throw new Error("Cannot resolve this path in " + this.storeType);
      } else if ((projectName != null) && (path == null)) {
        console.log("will fetch project " + projectName + "'s namespace");
        project = this.getProject(projectName);
        console.log(project);
        namespaced = {};
        _ref = project.rootFolder.models;
        for (index in _ref) {
          file = _ref[index];
          namespaced[file.name] = file.content;
        }
        namespaced = "" + projectName + "={";
        _ref1 = project.rootFolder.models;
        for (index in _ref1) {
          file = _ref1[index];
          namespaced += "" + file.name + ":'" + file.content + "'";
        }
        namespaced += "}";
        return result = namespaced;
      } else if ((projectName != null) && (path != null)) {
        console.log("will fetch " + path + " from " + projectName);
        getContent = function(project) {
          console.log(project);
          project.rootFolder.fetch();
          file = project.rootFolder.get(path);
          result = file.content;
          result = "\n" + result + "\n";
          return result;
        };
        return this.loadProject(projectName, true).done(getContent);
      }
    };

