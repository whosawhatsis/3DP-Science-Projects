
// OpenSCAD model to compute the velocity of a body in a Keplerian two-body-problem orbit
 
// Version to visualize speed of Halley's Comet around the sun. 
//Note that Halley is retrograde, so the speed relative to the earth adds about 30 km/s to the number you will calculate here
// File HalleysComet.scad

AU_to_mm = 4; //scaling factor for x and y axes
slice_angle = 1;
a = 17.8*AU_to_mm;  //semi-major axis - in AU times a scaling factor to fit the printer platform
b = 4.54*AU_to_mm; //semi-minor axis- in AU times a scaling factor to fit the printer platform
z_scale_factor = 70; //scale of z axis (arbitrary, since z is velocity and x,y are physical distance)

//use the OpenSCAD hull() function to create 
for(theta_hull = [0:slice_angle:359.99]) hull() 
    for(theta = [theta_hull, theta_hull + slice_angle], 
   // Use the parametric equations to generate an ellipse with one focus at (0,0)
        x = a * (cos(theta)) + sqrt(a*a-b*b), y = b * sin(theta), r = sqrt(x*x + y*y), 
    //Use the vis-viva equation to calculte the height to represent instantaneous velocity 
        h = z_scale_factor* sqrt((2/r - 1/a))) 
    // then generate a rectangular solid aligned with the tangent of the curve of the ellipse 
    // so that the hull operation makes the smoothest possible surface
			translate([x, y, h/2]) 
				rotate(theta)
                cube([3, .0001, h], center = true);

//generate the base and dots for the two foci
translate([sqrt(a*a-b*b), 0, 0]) scale([1, b/a, 1]) cylinder(r = a, h = 1);
translate([0,0,1])sphere(r = 1, h = 50);
translate([2*sqrt(a*a-b*b),0,1]) sphere(r =1);
    
  //Add a "cooling tower" of maximum height
    hmax = z_scale_factor* sqrt((2/(a-sqrt(a*a-b*b)) - 1/a));
    translate ([a/2,b+12,0]) cylinder (r=8, h=hmax);