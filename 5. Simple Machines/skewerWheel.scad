//OpenSCAD model to create wheels to fit on a bamboo skewer
//File skewerWheels.scad
//(c) 2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//size of skewers (mm). should be a friction fit
id = 3.1;
//wheel diameter
d = 25;
//minimum wall thickness (should be double your nozzle size)
wall = .8;

hub = d - wall * 6;
$fs = .2;
$fa = 1;

for(x = [1, -1], y = [1, -1])
  translate((d / 2 + 1) * [x, y, 0]) {
    linear_extrude(6) offset(wall / 3) offset(-wall / 3)
      difference() {
        circle(d / 2);
        circle(id / 2);
        for(a = [0:120:359]) rotate(a) {
          translate([0, -1, 0])
            square([hub / 2 - wall, id / 4]);
          difference() {
            circle(hub / 2);
            circle(id / 2 + wall);
            for(a = [0:120:359]) rotate(a)
              translate([0, -1, 0]) mirror([0, 1, 0])
                square([hub / 2 + wall, wall]);
          }
        }
      }

    linear_extrude(.4) difference() {
      circle(d / 2);
      circle(id / 2 + wall);
    }
  }