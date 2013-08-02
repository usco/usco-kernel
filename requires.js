requires = (function(root) {
    return function(resource) {
        return require(root+"/"+resource);
    }
})(__dirname);
