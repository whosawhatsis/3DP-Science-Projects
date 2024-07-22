//OpenSCAD program to create leaves with "drip tips"
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

size = 50;
hole = 4;
waviness = 1;

$fs = .2;
$fa = 2;

difference() {
  union() {
    linear_extrude(.6) scale(size / 25) for(j = [0, 1])
      mirror([j, 0, 0])
        for(_i = [for(i = [0:100 - 1]) i / 100])
          hull() for(i = [_i, _i + 1/100])
            translate([0, pow(i, 2) * 10, 0])
              rotate(180 * sqrt(i))
                scale([
                  .1,
                  pow(i, .5) * 10 - (-cos(i * 10 * 360) + 1) *
                    waviness
                ]) rotate(-135) square();
    linear_extrude(1) scale(size / 25) {
      for(j = [0, 1]) mirror([j, 0, 0]) 
        for(i = [for(i = [0:10]) i / 10])
          translate([0, pow(i, 2) * 10, 0])
            rotate(180 * sqrt(i)) hull() {
              scale([.1, pow(i, .5) * 10]) rotate(-135)
                square();
              circle(pow((i + 1), 1) * .5);
            }
      hull() for(j = [0, 1]) mirror([j, 0, 0])
        for(i = [for(i = [0:10]) i / 10])
          translate([0, pow(i, 2) * 10, 0])
            rotate(180 * sqrt(i))
              circle(pow((i + 1), 1) * .5);
    }
    
    linear_extrude(hole * 2, convexity = 5) difference() {
      circle((hole / 2 + 1.2));
      circle((hole / 2));
    }
  }
  linear_extrude(.8, center = true)
    scale(size / 25) offset(-.025) {
      for(j = [0, 1]) mirror([j, 0, 0])
        for(i = [for(i = [0:10]) i / 10])
          translate([0, pow(i, 2) * 10, 0])
            rotate(180 * sqrt(i)) hull() {
              scale([.1, pow(i, .5) * 10]) rotate(-135)
                square();
              circle(pow((i + 1), .5) * .1);
            }
      hull() for(j = [0, 1]) mirror([j, 0, 0])
        for(i = [for(i = [0:10]) i / 10])
          translate([0, pow(i, 2) * 10, 0])
            rotate(180 * sqrt(i))
              circle(pow((i + 1), .5) * .1);
    }
}