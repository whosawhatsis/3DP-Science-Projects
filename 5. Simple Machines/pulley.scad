//OpenSCAD model for making pulleys/blocks and tackles
//File pulley.scad
//(c) 2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

bearing_d = 4;
sheave_d = 32;
bore = 3.2;
width = 7;
clearance = 1;
bearing_fit = .1;
n = 1;
inner_wall = 1;
outer_wall = 2;

$fs = .2;
$fa = 2;

translate([0, 0, bore / 2 + outer_wall]) rotate([0, -90, 0])
  difference() {
    union() {
      linear_extrude(
        (width + clearance) * n
        + inner_wall * (n - 1)
        + outer_wall * 2,
        convexity = 10
      ) difference() {
        intersection() {
          circle(max(
            bearing_d,
            sheave_d) / 2 + width + outer_wall
          );
          square([bore + outer_wall * 2, 1000], center = true);
        }
        circle(bore / 2);
      }
      for(i = [-1, 1]) translate([
        0,
        i * (max(
          bearing_d,
          sheave_d
        ) / 2 + width + 3 + outer_wall),
        (
          (width + clearance) * n
          + inner_wall * (n - 1)
          + outer_wall * 2
        ) / 2
      ]) difference() {
        rotate([0, 90, 0]) linear_extrude(
          bore + outer_wall * 2,
          center = true,
          convexity = 5
        ) difference() {
          circle(3 + outer_wall);
          circle(3);
        }
        rotate(i * [-90, 0, 0])
          linear_extrude(100) for(j = [1, -1])
            hull() for(k = [0, 1])
              translate(j * [
                3 + outer_wall / 2 + 10 * k,
                0,
                0
              ])
                circle(3);
      }
    }
    for(i = [0:n - 1])
      translate([
        0,
        0,
        i * (width + clearance + inner_wall) + outer_wall
      ]) {
        rotate_extrude() union() {
          translate([bore / 2 + inner_wall, 0, 0])
            square([
              max(
                bearing_d,
                sheave_d
              ) / 2 + width - bore / 2 - inner_wall,
              width + clearance
            ]);
          translate([0, clearance / 4, 0])
          square([
            bore / 2 + inner_wall + 1,
            width + clearance / 2
          ]);
        }
      }
  }

for(i = [0:n - 1])
  translate([
    sheave_d / 2 + 1,
    i * (max(bearing_d, sheave_d) + 1),
    0]
  ) rotate_extrude()
    translate([bearing_d / 2 + bearing_fit, 0, 0])
      difference() {
        square([
          (sheave_d - bearing_d) / 2 - bearing_fit,
          width
        ]);
        translate([
          width / sqrt(2) + max(
            1,
            (sheave_d - bearing_d
          ) / 2
          - bearing_fit
          - width / sqrt(2) * (1 - sin(45))),
          width / 2,
          0
        ])
          circle(width / sqrt(2));
      }