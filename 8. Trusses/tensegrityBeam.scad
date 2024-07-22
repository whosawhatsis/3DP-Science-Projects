//OpenSCAD model of a beam for building tensegrity structures
//File tensegrityBeam.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

l = 120; // length of the rod
w = 6; // width of the rod, mm
h = 3; // depth in third dimension
hole = .5; // parameter to round off the edges of the slot 

$fs = .2;
$fa = 2;

difference() {
  linear_extrude(h, convexity = 5)
    offset((w - hole) * .24) offset((w - hole) * -.24)
      difference() {
        square([w, l], center = true);
        for(i = [1, -1]) translate([0, i * l / 2, 0])
          square([hole, w * 2], center = true);
      }
  for(i = [1, -1], j = [0, 1]) {
    translate([0, 0, h / 2]) mirror([0, 0, j])
      translate([0, i * l / 2, -h / 2 - 1]) for(k = [0:.1:1]) {
        hull() for(k = [k, k + .1]) linear_extrude(2 - k)
          offset(1 - sqrt(1 - pow(k, 2)))
            square([hole, w * 2], center = true);
        hull() for(k = [k, k + .1]) linear_extrude(2 - k)
          offset(1 - sqrt(1 - pow(k, 2)))
            translate([0, -i * w, 0]) circle(hole);
        linear_extrude(h) {
          square([hole, w * 2], center = true);
          translate([0, -i * w, 0]) circle(hole);
        }
    }
  }
}
