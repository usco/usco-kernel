
more detailed description of the intent/implem of the modules system in USCO
############################################################################

- In a module (since its not just "concat -> compile anymore")
	1.a coffee script (or not , yep, I intend to allow .js files as well, given the latest additions to javascript : classes etc)
	1.b generate source map (for correct error mapping etc)
	2. generate AST ( abstract syntax tree ) (YAY indeed)
	3. analyse AST 
	4. *preFetch imports, includes* (very important , as these are async, but I "cheat" and make it seem sync): 
	for every import/include statement we found in the AST, we fetch the data (stl, coffee, amf whatever), 
	and store either the successfully imported data OR the error (which we don't report yet, as our script is not supposed to have been evaluated yet:
	yes, a big fat cheat !
	
	5.resolve all dependencies, walking the "includes" graph
	6a. wrap our code  + inject function tracing code , transform tracing code etc
	6b . evaluate our code : creates meshes, calculate CSG bit with threejs  etc

Transform history/tracking :
############################

A lot of things are still missing: for example I am not sure if object transform tracking should be in the AST analysis step or directly added in the
transformations methods :

What is transform history/ tracking?

- Part instanciation position (in the code) needs to be injected into instances (via ast)

knowing that the operations on your cube were : 
cube->translate()->rotate()->translate()->mirror()->rotate() etc

#NOTE : not sure about the following just yet

since we will have that data in the object instances , it can be manipulated by the on screen controls:
- for example if you have defined a cube like this (in code):
	myCube = new Cube(20)

- and you translated it, (still in code):
	cube.translate([20,0,0])

- if you compile your code, you should have a cube that has been translated once AND that "knows" it has been translated once
- if you now use the onscreen VISUAL controls, to do a rotation by 45° on X, it adds a rotate([45,0,0]) transform to the history

Npm package support:
####################
Given how similar the Module system is to npm packages, it could be a good way to distribute packages ???

