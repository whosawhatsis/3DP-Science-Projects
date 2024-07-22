//OpenSCAD model to creates all three classes of lever
//File lever.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//two lengths of the lever
lever = [70, 30];
//class of lever
class = 1; //[1, 2, 3]
//height of point of fulcrum, in mm
fulcrum_height = 30;
//width in mm
width = 30;

echo(str("mechanical advantage: ", 
  (class == 1) ? str(lever[0], ":", lever[1]) :
  (class == 2) ? str(lever[0] + lever[1], ":", lever[1]) :
  (class == 3) ? str(lever[0], ":", lever[0] + lever[1]) :
  0
));


linear_extrude(width, convexity = 5) difference() {
  intersection() {
    square(fulcrum_height * 2, center = true);
    rotate(-135) square(fulcrum_height * sqrt(2));
  }
  difference() {
    square(fulcrum_height * 2 - 10, center = true);
    intersection_for(a = [1, -1]) rotate(-135 + a * (45 - 15))
      square(fulcrum_height * sqrt(2));
  }
}

difference() {
  linear_extrude(width, convexity = 5) difference() {
    translate([-5 - ((class == 1) ? lever[1] : 0), 0, 0])
      square([10 + lever[0] + lever[1], 5]);
    translate([0, 2.5, 0]) rotate(-135) square(5);
    translate([lever[0], 2.5, 0])
      rotate(((class == 3) ? -135 : 45)) square(5);
    translate([
      ((class == 1) ? -lever[1] : lever[0] + lever[1]),
      2.5,
      0
    ]) rotate(((class == 2) ? -135 : 45)) square(5);
    
  }
  translate([lever[0] / 2, 5, width / 2])
    rotate([90, 0, 180])
      linear_extrude(height = 1, center = true, convexity = 5)
        text(
          str(lever[0]),
          size = min(width / 3,
          lever[0] / 3),
          halign = "center",
          valign = "center"
        );
  translate([
    (class == 1) ? -lever[1] / 2 : lever[0] + lever[1] / 2,
    5,
    width / 2
  ]) rotate([90, 0, 180])
      linear_extrude(height = 1, center = true, convexity = 5)
        text(
          str(lever[1]),
          size = min(width / 3,
          lever[1] / 3),
          halign = "center",
          valign = "center"
        );
}
