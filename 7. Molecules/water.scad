//OpenSCAD model of a water molecule for building ice crystals
//File water.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//Oxygen atom diameter, mm
Od = 25;
//Hydrogen atom diameter, mm
Hd = 12.5;
//Offset between centers of O and H atoms, mm
OHspacing = 12.5;
//diameter of the peg, mm
peg = 6.25;
//Tolerance (empty space) between peg in hole and peg
tol = .2;
//length of the peg
peg_len = 12.5;

$fs = .2;
$fa = 2;

angle = 104.5; //[104.5:water, 109.5:tetrahedral]

for(a = [0, 180]) rotate(a)
  translate([-Od / 3, peg_len * 1.5, 0,])
    rotate(angle / 2 - 90) half();

//Now create the half a molecule
module half() difference() {
  union() {
    sphere(Od / 2);
    for(i = [-1, 1]) rotate(angle / 2 * i) {
      translate([OHspacing, 0, 0]) sphere(Hd / 2);
      rotate([0, -90, 0])
        translate([0, 0, -(Od + Hd) / 2 - peg_len]) peg();
    }
  }
  for(i = [-1, 1]) rotate([0, angle / 2 * i - 90, 0])
    translate([0, 0, peg / 2]) peg(true);
  translate([0, 0, -100 + tol / 2]) cube(200, center = true);

}

module peg(hole = false) difference() {
  union() {
    rotate_extrude() intersection() {
      offset(hole ? tol : 0) {
        hull() {
          translate([0, peg / 2, 0]) circle(peg / 2);
          translate([0, peg_len, 0]) square(peg / 2);
        }
        if(hole) translate([peg / 2 - .25, Od / 2 - peg, 0])
          circle(1);
      }
      translate([0, -peg, 0]) square(1000);
    }
    if(!hole) translate([0, peg / 2 - .25, Od / 2 - peg])
      sphere(1);
  }
  if(!hole) rotate([0, -90, 0])
    linear_extrude(peg, center = true)
      offset(.45) offset(-.45) difference() {
        offset(1.5) offset(-1) square(Od / 2 - peg / 2);
        offset(.5) offset(-1) square(Od / 2 - peg / 2);
        square(peg, center = true);
      }
}