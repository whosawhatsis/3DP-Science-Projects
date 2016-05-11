// Model to take externally-generated surface data
// And to then create a surface in OpenSCAD with it
// File SurfaceFromData.scad
difference() {
   translate([0, 0, 2]) surface(file = "sinusoids.dat", center = true, convexity = 5);
   surface(file = "sinusoids.dat", center = true, convexity = 5);
}
