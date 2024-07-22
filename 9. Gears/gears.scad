//OpenSCAD model to create a two-stage gear reduction
//File gears.scad
//(c) 2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//Diameter of the gear shafts
shaft = 10;
//Gear module
mod = 2.5;
//Number of teeth for the smaller and larger gears
teeth = [10, 20];
//Angle used for generating the shape of the gear teeth
pressure_angle = 14.5;
//Height of each gear (axial dimension)
height = mod * 5;
//Base thickness
base = 3;
//Additional radius for holes around shafts
clearance = .5;

$fs = .2;
$fa = 2;

distance = mod * (teeth[0] + teeth[1]) / 2;

module base() {
  linear_extrude(base) hull() for(i = [0, 1])
    translate([i * distance, 0, 0])
      circle(mod * max(teeth) / 2 + mod);
  linear_extrude(base + 1) for(i = [0, 1])
    translate([i * distance, 0, 0]) circle(shaft / 2 + 1);
  linear_extrude(base + 1 + height) offset(2) offset(-2)
    difference() {
      hull() for(i = [0, 1]) translate([i * distance, 0, 0])
        circle(mod * max(teeth) / 2 + mod);
      circle(mod * teeth[0] / 2 + mod + clearance * 1.5);
      translate([distance, 0, 0])
        circle(mod * teeth[1] / 2 + mod + clearance * 1.5);
    }
  linear_extrude(base + 2 + height * 2) circle(shaft / 2);
  linear_extrude(base + 3 + height * 3)
    translate([distance, 0, 0]) circle(shaft / 2);
}

base();
%translate([distance, 0, base + 1])
  rotate(90) gear3();
%translate([0, 0, base + 2 + height * 2])
  rotate([180, 0, 90]) gear2();
%translate([distance, 0, base + 3 + height * 3])
  rotate([0, 180, 90]) gear1();

translate([distance * 2 + mod * 2 + 1, -distance / 4, 0])
  gear1();
translate((mod * max(teeth) + mod * 2 + 1) * [1, 1, 0])
  gear2();
translate([0, mod * max(teeth) + mod * 2 + 1, 0])
  gear3();

module gear1() {
  linear_extrude(height) difference() {
    union() {
      circle(mod * teeth[0] / 2 + mod);
      hull() for(i = [0, 1]) translate([0, i * distance, 0])
        circle(mod * (teeth[1] - teeth[0]) / 8 + 1);
    }
    circle(shaft / 2 + clearance);
    translate([0, distance / 2, 0])
      circle(mod * (teeth[1] - teeth[0]) / 8 - 1);
  }
  linear_extrude(height * 2 + 2) difference() {
    circle(shaft / 2 + clearance + 1);
    circle(shaft / 2 + clearance);
  }
  intersection() {
    cylinder(r = teeth[0] * mod / 2 + mod, h = height * 2 + 1);
    translate([0, 0, height * 1.5 + 1])
      herringbone(height * 2, -360 / teeth[0] * 2)
        gear(teeth[0], mod, shaft / 2 + clearance);
  }
}

module gear2() {
  difference() {
    translate([0, 0, height / 2]) rotate(180 / teeth[1])
      herringbone(height, 360 / teeth[1])
        gear(teeth[1], mod, shaft / 2 + clearance);
    rotate(180) translate([0, -distance / 2, 0])
      linear_extrude(height)
        circle(mod * (teeth[1] - teeth[0]) / 8 - 1);
  }
  intersection() {
    linear_extrude(height * 2 + 1) 
      circle(teeth[0] * mod / 2 + mod);
    translate([0, 0, height * 1.5 + 1]) rotate(180 / teeth[0])
      herringbone(height * 2, 360 / teeth[0] * 2)
        gear(teeth[0], mod, shaft / 2 + clearance);
  }
}

module gear3() difference() {
  translate([0, 0, height / 2])
    herringbone(height, 360 / teeth[1])
      gear(teeth[1], mod, shaft / 2 + clearance);
  translate([0, distance / 2, 0]) linear_extrude(height)
    circle(mod * (teeth[1] - teeth[0]) / 8 - 1);
}

module herringbone(thick = 12, angle = 0)
  for(m = [0, 1]) mirror([0, 0, m])
    linear_extrude(thick / 2, twist = angle, convexity = 5)
      children();

module gear(teeth, mod = 2, bore = 0) {
  baser = teeth * cos(pressure_angle);
  difference() {
    scale(mod / 2) offset(-1.2) offset(1.2) union() {
      circle(teeth - 2.5);
      for(tooth = [0:teeth]) rotate(tooth * 360 / teeth)
        intersection() {
          circle(teeth + 2);
          intersection_for(i = [0, 1]) mirror([i, 0, 0])
            rotate(-360 / teeth / 4)
              polygon([
                for(i = [-teeth / 10:.1:teeth / 2])
                  sqrt(sign(i) * (2 * PI * i)^2 + baser^2) * [
                    -sign(i) * 
                    sin(
                      i * 360 / baser -
                      atan2(2 * PI * i, baser)
                    ),
                    cos(
                      i * 360 / baser -
                      atan2(2 * PI * abs(i), baser)
                    )
                  ]
              ]);
        }
    }
    circle(bore);
  }
}
