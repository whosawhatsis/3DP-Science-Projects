// OpenSCAD model to compute gravitational potential wells for earth-moon system
 
 // Gravity potential for a unit test mass is a constant times the sum of mass of other bodies 
 // Divided by distance from test mass to those bodies
 // File earthMoon.scad
 
  constant= 3*0.0667408 ;   //km^3/kg-s^2 -- factor of 2 added to exaggerate vertical scale
  mass_earth = 5970;  // in 10^21 kg
  mass_moon =72; // in 10^21 kg
  height_model = 50; // z height of printed model, in mm 
 
  //Each square in x and y is 5,000 km on a side in this model
  //Earth-moon 76.8 squares apart
  //Earth radius is 0.6 squares 
  
 function f(x, y) = max( 0,  height_model-
               (constant*mass_earth/sqrt(x*x+(y-82.3)*(y-82.3)) +
               constant*mass_moon/sqrt(x*x+(y-5.5)*(y-5.5)) )
                                 );  //

thick = 0; //set to 0 for flat bottom. else mm thickness of surface
xmax = 35; //Number of points in x direction - 1;  
ymax = 120; // Number of points in y direction -1;  

// If you want a rough surface (to make it more tactile) set blocky=true. 
// Otherwise surface will be smoothed
blocky = false; //if true, xmax and ymax must be less than 100.


//number of points that will be plotted
toppoints = (xmax + 1) * (ymax + 1);

//next section generates the points in the arriay
points = concat(
	[for(y = [0:ymax], x = [0:xmax]) [x, y, f(x, y)]], // top face
	(thick ? //bottom face
		[for(y = [0:ymax], x = [0:xmax]) [x, y, f(x, y) - thick]] : 
		[for(y = [0:ymax], x = [0:xmax]) [x, y, 0]]
	)
);

zbounds = [min([for(i = points) i[2]]), max([for(i = points) i[2]])];
	
//create triangles from quad
function quad(a, b, c, d, r = false) = r ? [[a, b, c], [c, d, a]] : [[c, b, a], [a, d, c]]; 

faces = concat(
      //build top and bottom
	[for(bottom = [0, toppoints], i = [for(x = [0:xmax - 1], y = [0:ymax - 1]) 
		quad(
			x + (xmax + 1) * (y + 1) + bottom,
			x + (xmax + 1) * y + bottom,
			x + 1 + (xmax + 1) * y + bottom,
			x + 1 + (xmax + 1) * (y + 1) + bottom,
			bottom
		)], v = i) v],
	[for(i = [for(x = [0, xmax], y = [0:ymax - 1]) //build left and right
		quad(
			x + (xmax + 1) * y + toppoints,
			x + (xmax + 1) * y,
			x + (xmax + 1) * (y + 1),
			x + (xmax + 1) * (y + 1) + toppoints,
			x
		)], v = i) v],
	[for(i = [for(x = [0:xmax - 1], y = [0, ymax]) //build front and back
		quad(
			x + (xmax + 1) * y + toppoints,
			x + 1 + (xmax + 1) * y+ toppoints,
			x + 1 + (xmax + 1) * y,
			x + (xmax + 1) * y,
			y
		)], v = i) v]
);

//Now either generate the surface as discrete cuboids
// or smoothly with the polyhedron function

if(blocky) for(i = [0:toppoints - 1]) translate(points[toppoints + i]) cube([1.001, 1.001, points[i][2] - points[toppoints + i][2]]);
else polyhedron(points, faces);

echo(zbounds);
// end of code listing.
