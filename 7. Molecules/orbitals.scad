//OpenSCAD model of an atom - nucleus and s and p orbitals
//File orbitals.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//If you want to make one of the pieces a different color,
//you can uncomment one of the following three lines to 
//make an STL of only one part, instead of the whole set.

// !s_orbital();
// !p_orbital();
// !nucleus();

//Plate the p orbitals, s orbitals, and nucleus for printing
translate([-41, 0, 0]) {
  for(i = [0:2]) translate([0, i * 22, 5]) rotate([0, 90, ])
    rotate(-16) p_orbital();
  for(i = [-1, 1]) translate([i * 20, -30, 17]) s_orbital();
  translate([20, -30, 10 * (sin(52.5))]) nucleus();
}

$fs = .2;
$fa = 2;

//Display the parts to show how they are assembled
//% modifier means they will not be included when rendering
%translate([41, 0, 0]) {
  nucleus();
  for(l = [0, 1]) rotate([180 * l, 0, 0]) s_orbital();
  for(i = [0:2]) rotate([
    i ? 90 : 0,
    i ? ((i == 1) ? 45 : 135) : 0,
    i ? ((i == 1) ? 0 : -90) : 45
  ]) 
    p_orbital();
}

//create the nucleus (sphere with a flat side for printing)
module nucleus() scale(1.0) difference() {
  sphere(10);
  translate([0, 0, -10 * (1 + sin(52.5))])
    cube(20, center = true);
}

//create s orbital halves
module s_orbital() difference() {
  intersection() {
    sphere(22);
    cube(17 * 2, center = true);
  }
  sphere(18);
  for(i = [-1:1]) rotate([0, 90 * i, 45 * i + 45]) {
    cylinder(r = 10.5, h = 100, center = true);
  }
  translate([0, 0, 50 + 2]) cube(100, center = true);
  intersection() {
    union() {
      rotate([90, 0, 45])
        linear_extrude(100, center = true, convexity = 5)
          for(m = [0, 1]) mirror([m, 0, 0])
            translate([20, 0, 0]) rotate(-5)
              translate([0, -3, 0]) square(10);
      rotate([90, 0, -45])
        linear_extrude(100, center = true, convexity = 5)
          for(m = [0, 1]) mirror([m, 0, 0])
            translate([20, 0, 0]) rotate(5 + 180)
              translate([0, -3, 0]) square(10);
    }
    translate([0, 0, 50 - 2]) cube(100, center = true);
  }
}

//create p orbital lobes
module p_orbital() difference() {
  union() {
    for(i = [1, -1]) hull() {
      sphere(2);
      translate([0, 0, i * 30]) sphere(10);
    }
    intersection() {
      sphere(12);
      linear_extrude(height = 100, center = true) hull()
        for(j = [0, 1]) translate([0, j * 15, 0])
          circle(5 - 4 * j);
    }
  }
  for(i = [1, -1]) rotate([-90, 0, i * 45]) hull() {
    sphere(1);
    translate([0, 0, 30]) sphere(10);
  }
  sphere(10);
  rotate(16) translate([55, 0, 0]) cube(100, center = true);
}