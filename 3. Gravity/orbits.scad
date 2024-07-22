//OpenSCAD model to compute the velocity of a body in a
//Keplerian two-body-problem orbit
//File HalleysComet.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

wall = 2;
//scaling factor for x and y axes
AU_to_mm = 40;
preset = 0; // [0:"",1:Mercury,2:Venus,3:Earth,4:Mars,5:Halley]
//degrees per segment (smaller = smoother, but slower render)
slice_angle = 1;
//semi-major axis in AU (if using "custom")
semimajor = 17.94;
//semi-minor axis in AU (if using "custom")
semiminor = 4.59;
//scale of z axis (arbitrary since z is velocity, not distance)
z_scale_factor = 25;
//keep this consistent between models to compare velocities

planets = [[semimajor, semiminor],
  [0.38709893, 0.3788], //Mercury
  [0.72333199, 0.7233], //Venus
  [1.00000011, 0.9999], //Earth
  [1.52366231, 1.5170], //Mars
  [17.94, 4.59]         //Halley's Comet
//Note that Halley is retrograde, so the speed relative to the
//relative velocity will be the sum, rather than the difference
];

size = AU_to_mm * planets[preset];

//reverse if semiminor > semimajor
a = max(size);
b = min(size);

echo(str("Long dimension is ", a * 2 + wall, " mm."));

$fs = .2;
$fa = 2;

//generate the wall using a chain hull 
for(theta = [0:slice_angle:359.99]) hull() 
  for(
    theta = [theta, theta + slice_angle],
    //generate an ellipse with one focus at (0, 0)
    x = a * (cos(theta)) + sqrt(pow(a, 2) - pow(b, 2)),
    y = b * sin(theta),
    r = sqrt(pow(x, 2) + pow(y, 2)),
    //Use the vis-viva equation to calculate the height
    //to represent instantaneous velocity
    h = z_scale_factor * sqrt(AU_to_mm) * sqrt((2 / r - 1 / a))
  )
    //generate a series of cuboids aligned along the wall
    translate([x, y, h / 2])
      //use tangent angle to the wall for uniform thickness
      rotate(atan2(a * y, pow(b, 2) * cos(theta)))
        cube([wall, .0001, h], center = true);

//generate the base
difference() {
  union() {
    translate([sqrt(pow(a, 2) - pow(b, 2)), 0, 0])
      scale([1, b / a, 1]) cylinder(r = a, h = 1);
    intersection() {
      //use a cone to represent the location of the sun
      cylinder(r1 = 5, r2 = 0, h = 5);
      translate([sqrt(pow(a, 2) - pow(b, 2)), 0, 0])
        scale([1, b / a, 1]) cylinder(r = a, h = 5);
    }
  }
  //make the sun cone hollow, to align stacked prints
  translate([0, 0, -1]) cylinder(r1 = 5, r2 = 0, h = 5);
  //use a hole to show the other focus
  translate([2 * sqrt(pow(a, 2) - pow(b, 2)), 0, 1])
    cylinder(r = 1, h = 10, center = true);
}