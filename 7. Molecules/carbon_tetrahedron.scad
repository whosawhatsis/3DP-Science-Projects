//OpenSCAD model of a carbon atom - nucleus and sp3 orbitals
//File carbon_tetrahedron.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

size = 20;
thick = size / 10;

$fs = .2;
$fa = .2;

translate([0, -size * 2 / 3, 0]) intersection() {
  translate(size / 2 * [0, 0, sin(55)]) sphere(size / 2);
  translate(size / 2 * [0, 0, 1]) cube(size, center = true);
}

for(i = [0:3]) translate([0, i * (size + 1), 0]) 
  translate([0, 0, size / 5]) rotate([0, 82, 0]) for(a = [0])
    rotate([a * (acos(1/3)), a * 180, 0]) difference() {
      difference() {
        union() {
          intersection() {
            sphere(size / 2 + thick);
            translate([-size / 10, 0, -500]) cube(1000);
          }
          translate([0, 0, -size / 5]) rotate_extrude()
            intersection() {
              translate([0, -1000, 0]) square(2000);
              union() for(lobe = size * [-.5, 1.5]) hull() {
                square(.1, center = true);
                translate([0, lobe, 0])
                  circle(abs(lobe) / 3);
              }
            }
        }
        rotate([180 - acos(1/3), 0, 0]) {
          intersection() {
            sphere(size / 2 + thick + .1);
            translate([-1000, -1000, -500]) cube(1000);
          }
          intersection() {
            translate([0, 0, -size / 5]) rotate_extrude()
              intersection() {
                translate([0, -1000, 0]) square(2000);
                union() for(lobe = size * [-.5]) hull() {
                  square(.1, center = true);
                  translate([0, lobe, 0])
                    circle(abs(lobe) / 3);
                }
              }
              translate([-1000, -500, -500]) cube(1000);
          }
        }
      }
      sphere(size / 2);
      rotate([0, -82, 0]) translate([0, 0, -1000 - size / 5])
        cube(2000, center = true);
    }
