// OpenSCAD program to print out an arbitrary surface defined as z = f(x,y)
 // Either prints the surface as two sided and variable thick = thickness
 // Or if thick = 0, prints a top surface with a flat bottom
 // File multipleWaves.scad

factor =1;
lambda=4;
 xc1 = 49.5 -10;
 xc2 = 49.5 + 10;

 function radius(x,y, xc, yc) = sqrt( (x-xc)*(x-xc) + (y-yc)*(y-yc) );
 function f(x, y) =  factor* pow ( (cos( (360/lambda)*radius(x,y,xc1,0) ) + cos( (360/lambda)*radius(x,y,xc2,0) ) ),2) +2;
 //You are computing sin ( (2*PI/lambda) * (180/PI) r); equation above simplifies to get (360*r/lambda). OpenSCAD presumes degrees. 
 
 //z height, in mm

thick = 0; //set to 0 for flat bottom. else mm thickness of surface
xmax = 99; //Number of points in x direction - can be more than 99 if we do not use blocky=true
ymax = 99; // Number of points in y direction -  can be more than 99 if we do not use blocky=true

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
