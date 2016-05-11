// OpenSCAD model to compute gravitational potential wells of Algol system
  
 // Gravity potential for a unit test mass is a constant times the sum of mass of other bodies 
 // Divided by distance from test mass to those bodies
 // File Algol.scad
 
 // This is for the trinary star Algol, data from https://en.wikipedia.org/wiki/Algol
 
  constant= 20; //here just a scaling factor in Z
  mass_Aa1 = 4.5;  // masses relative to Aa2
  mass_Aa2 =1; 
  mass_Aab = 2; 
  
  //distances in milliarcseconds as seen from earth
  //Aa1 to Aa2 = 2.15; Aa1 to Ab = 93.4
  height_model = 40; // z height of printed model, in mm 
 
  //Each square in x and y represents is  0.2 microarcsecond seen from earth on a side 
 // The Aab star will not explicitly appear in this version but its influence is included for completeness 
  
 function f(x, y) = max( 0,  height_model- constant * (
              mass_Aa1 /sqrt(x*x+(y-20)*(y-20)) +
              mass_Aa2/sqrt(x*x+(y-62.2)*(y-62.2)) +
              mass_Aab/sqrt(x*x+(y-1888)*(y-1888)) 
               
                              )
                                 );  //

thick = 0; //set to 0 for flat bottom. else mm thickness of surface
xmax =25; //Number of points in x direction - 1;  
ymax = 100; // Number of points in y direction -1;  

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
