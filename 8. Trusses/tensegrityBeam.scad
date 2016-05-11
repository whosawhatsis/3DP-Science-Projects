//Program to print tensegrity beam
//File name: tensegrityBeam.scad

l = 120; // length of the rod
w = 6; // width of the rod, mm
h = 3; // depth in third dimension
hole = .5; // parameter to round off the edges of the slot 

$fs = .5;
$fa = 2;

difference() {
  linear_extrude(h, convexity = 5) offset((w - hole) * .24) offset((w - hole) * -.24) difference() {
    square([w, l], center = true);
    for(i = [1, -1]) translate([0, i * l / 2, 0]) square([hole, w * 2], center = true);
  }
  for(i = [1, -1], j = [0, 1]) {
    translate([0, 0, h / 2]) mirror([0, 0, j]) translate([0, i * l / 2, -h / 2 - 1]) hull() {
      linear_extrude(1 + hole) offset(-hole/2 + .1) square([hole, w * 2], center = true);
      linear_extrude(1) offset(hole/2 + .1) square([hole, w * 2], center = true);
    }
  }
}
