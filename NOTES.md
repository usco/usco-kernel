#preprocessor approaches:#
 either way, it is a complex matter to solve issues of async load of remote files...
 - purely text based, fully preemtive: (LEVEL 0, simplest at this point)
 	* parse the source for includes and imports (wherever they are in the source, even if within a closure)
 	* evaluate those imports, caching the data
 	* replace (on the fly , invisible) the original source for those calls with either dummy methods or ""
 
    *important : the call hierarchies/dependencies graphs still needs to be generated correctly
 
 - using generators / yield : (LEVEL 1): IMPORTANT : requires generators support !!
 	* wrap module elements using async loading in 'function *' instead of function, execute with Q.spawn/Q.async
