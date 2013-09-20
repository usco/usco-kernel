

class BaseMaterial
  constructor:->
    #TODO: brainstorm : http://en.wikipedia.org/wiki/List_of_materials_properties
    #some properties would be calculated obviously
    #TODO: also see phyiscal based shading/ rendering http://seblagarde.wordpress.com/2011/08/17/feeding-a-physical-based-lighting-mode/
    #http://seblagarde.wordpress.com/2012/04/30/dontnod-specular-and-glossiness-chart/
    
    #optical : #hmm all of these depend not only on the raw material used, but on how the material is structured
    #within an object
    @absorbtion = ""
    @color = ""#color : RGBA
    @luminosity = ""
    @reflectivity = ""
    @refractivity = ""
    @scatering = ""
    @transmitance = ""
    #@specular = "" #color + texture + shader ??
    
    
    
    #physical/mecanical
    @restitution = "" #elasticity
    @friction    = ""
    @conductivity = ""
    @permeability = ""
    @compressiveStrenght = ""
    @hardness = ""
    
    @weight = "" #atomic mass, specific weight ?
    
    @type = "" #["PLA","ABS" etc] or plastic, metal ? but then it would also determine other properties ?

    shine= 1500
    spec= 1000
    opacity = 1
    @threeJsMaterial = new THREE.MeshPhongMaterial({color:  0xFFFFFF , shading: THREE.SmoothShading,  shininess: shine, specular: spec, metal: false}) 
    

module.exports = BaseMaterial