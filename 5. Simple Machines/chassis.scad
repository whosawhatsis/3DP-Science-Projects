//OpenSCAD model of a printable chassis for skewerWheels.scad
//File chassis.scad
//(c) 2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

size = [40, 100];
wheelbase = 80;
hole = 4;

$fs = .2;
$fa = 2;

difference() {
  union() {
    linear_extrude(hole + 2, center = true)
      offset(2) offset(-2) square(size, center = true);
    for(i = [-1, 1]) translate(i * [0, wheelbase / 2, 0])
      rotate([0, 90, 0])
        linear_extrude(size[0] + 2, center = true)
          intersection() {
            hull() {
              circle(hole / 2 + 1);
              scale([sqrt(2), .5])
                circle(hole / 2 + 1, $fn = 4);
            }
            square(hole + 2, center = true);
          }
  }
  for(i = [-1, 1]) translate(i * [0, wheelbase / 2, 0])
    rotate([0, 90, 0])
      linear_extrude(size[0] + 3, center = true)
        circle(hole / 2);
}