//OpenSCAD model to print out a pair of NACA airfoils 
//(to make a complete wing)
//Plus a support that can be used for measuring lift
//Formulation of NACA airfoil mathematics based on equations in
//NACA Report 460, "The Characteristics of 78 Related Airfoil
//Sections From Tests in the Variable-Density Wind Tunnel"
//(1935) by E.N. Jacobs, K.E. Ward and R.M. Pinkerton.
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

NACA = 2412; //4-digit NACA airfoil number
chord = 60; //root chord length, mm
length = 120; //wing length, mm

taper = 1; //ratio of chord at tip over chord at root
sweep = 0; //sweep angle in degrees. 0 = no sweep
dihedral = 0; //dihedral angle in degrees. 0 = no dihedral

sting_size = 20; //sting cross section in mm
sting_length = 100; //sting vertical bar length, in mm

sting_angle = [0:5:25]; //range of angle of attack possible

tolerance = .3;
nest = true; //Attempt to nest parts for printing
//Some values may result in nested parts overlapping

steps = 200;
step = 1/steps;

$fs = .5;
$fa = 2;

airfoil_with_sting();
%mirror([0, 0, 1]) airfoil_with_sting();
%translate([
  chord * 1.5 + sting_size/4,
  -sting_length,
  -sting_size/2
]) base();

if(nest) {
  translate([
    chord * 1.5 - sting_size / 2 - 5,
    -65,
    0
  ]) rotate(-65) base();
  translate([
    chord * 2.5 - max(chord, 40) - sting_size / 2,
    sting_size / 2,
    0
  ]) mirror([1, 0, 0]) airfoil_with_sting();
} else {
  translate([0, 50, 0]) base();
  translate([-5, 0, 0]) mirror([1, 0, 0]) airfoil_with_sting();
}

//Extract the wing parameters from the NACA number 
//and return them as an array of [a, b, cd]
function parameters(NACA) = [(NACA - NACA % 1000) / 100000,
  (NACA % 1000 - NACA % 100) / 1000, NACA % 100];

echo("a", parameters(NACA)[0]);
echo("b", parameters(NACA)[1]);
echo("cd", parameters(NACA)[2]);

//Develop the camber line,
function camber(x, p) = (x < p[1]) ? 
  p[0] / pow(p[1], 2) * (2 * p[1] * x - pow(x, 2))
:
  p[0] / pow(1 - p[1], 2) *
  (1 - 2 * p[1] + 2 * p[1] * x - pow(x, 2));

//Determine the thickness 
function thickness(x, p) = (p[2] / 20) * (
  0.29690 * sqrt(x)
  - 0.12600 * x
  - 0.35160 * pow(x, 2)
  + 0.28430 * pow(x, 3)
  - 0.10150 * pow(x, 4)
);

//Find instantaneous angle of slope of the camber curve, theta,
//so that the thickness component can be computed perpendicular
//to the camber line
function theta(x, p) = atan(
  x < p[1] ?
    p[0] / pow(p[1], 2) * (2 * p[1] - 2 * x)
  :
    p[0] / pow(1 - p[1], 2) * (2 * p[1] - 2 * x)
);

//Utility function for converting 2D points to 3D
function z(points, z = 0) = [for(p = points) [p[0], p[1], z]];

//Utility function for adding to all points in an array
function add(v, plus) = [for(i = v) i + plus];

//Calculates surface points to be stitched together later
function airfoil_points(p, chord) = concat(
  //top
  [for(x = [0:step:1 - step]) chord * [
    x - thickness(x, p) * sin(theta(x, p)),
    camber(x, p) + thickness(x, p) * cos(theta(x, p))
  ]],
  //bottom
  [for(x = [1:-step:step]) chord * [
    x + thickness(x, p) * sin(theta(x, p)),
    camber(x, p) - thickness(x, p) * cos(theta(x, p))
  ]]
);

module airfoil_cross_section(p, chord)
  polygon(airfoil_points(p, chord));

//Build the wing by stitching together the points of the root
//and tip cross-sections. This is the fastest method to
//compute, and allows all combinations of sweep and taper.
module airfoil(
  p = parameters(NACA), chord = chord, length = length,
  taper = taper, sweep = sweep, dihedral = dihedral
) {
  polyhedron(
    concat(
      z(airfoil_points(p, chord)), 
      z(
        add(
          add(
            airfoil_points(p, chord),
            [-chord / 4, 0]
          ) * taper,
          [
            chord / 4 + length * tan(sweep),
            length * tan(dihedral)]
        ), length
      )
    ), concat(
      [for(i = [1:steps - 1]) [i, steps * 2 - i, i + 1]],
      [for(i = [1:steps - 1]) [i,
        (steps * 2 - i + 1) % (steps * 2), steps * 2 - i]],
      [for(i = [1:steps - 1]) add([i, i + 1,
        steps * 2 - i], steps * 2)],
      [for(i = [1:steps - 1]) add([i, steps * 2 - i,
        (steps * 2 - i + 1) % (steps * 2)], steps * 2)],
      [for(i = [0:steps * 2 - 1]) [i, (i + 1) % (steps * 2),
        (i + 1) % (steps * 2) + steps * 2]],
      [for(i = [0:steps * 2 - 1]) [i,
        (i + 1) % (steps * 2) + steps * 2, i + steps * 2]]
    )
  );
}

*translate([chord / 4, 0, 0]) rotate([0, sweep, 0]) %cube(100);

module airfoil_with_sting() translate([0, 0, 0]) union() {
  airfoil();
  hull() {
    translate([chord * 0.3, chord * parameters(NACA)[0], 0])
      intersection() {
        sphere(r = chord * thickness(0.3, 
          parameters(NACA)));
          translate([0, 0, chord/2])
            cube(chord, center = true);
    }
    translate([
      chord * 1.5 - sting_size/4,
      chord * parameters(NACA)[0],
      0
    ])
      intersection() {
        rotate([0, -90, 0])
          rotate_extrude() rotate(-90) intersection() {
            airfoil_cross_section(
              parameters(0040),
              sting_size
            );
            square(sting_size);
          }
        translate([0, 0, sting_size])
          cube(sting_size * 2, center = true);
    }
  }
  difference() {
    translate([
      chord * 1.5 - sting_size/4,
      chord * parameters(NACA)[0],
      0
    ]) 
      rotate([90, 0, 0])
        linear_extrude(sting_length) intersection() {
          airfoil_cross_section(parameters(0040), sting_size);
          square(sting_size);
        }
    translate([chord * 1.5 + sting_size/4, -sting_length, -1])
      cylinder(r = sting_size/2 - 3, h = sting_size);
  }
  translate([chord * 1.5 + sting_size/4, -sting_length, 0])
    intersection() {
      rotate([-90, 0, 0]) rotate_extrude(convexity = 10)
        hull() {
          difference() {
            circle(r = sting_size / 2 + 1);
            translate([0, -50, 0]) square(100);
          }
          translate([-50, 0, 0]) circle(r = 1);
        }
      linear_extrude(sting_size / 4, convexity = 10)
        difference() {
          hull() {
            circle(r = sting_size / 2);
            translate([-50, 0, 0]) circle(r = 1);
          }
          circle(r = sting_size/2 - 4, $fn = 8);
        }
    }
}

module base() difference() {
  union() {
    difference() {
      linear_extrude(sting_size, convexity = 10) difference() {
        intersection() {
          circle(50 + 5);
          translate([-100 + sting_size, 100 - sting_size, 0])
            square(200, center = true);
          rotate(-max([for(i = sting_angle) i]))
            translate([-100 + sting_size, -100 + 5, 0])
              square(200, center = true);
        }
        circle(50 - 2);
        for(i = sting_angle) rotate(-i) hull() {
          circle(r = sting_size / 2 + 3);
          translate([-50, 0, 0]) circle(r = 1 + tolerance);
        }
      }
      for(i = sting_angle) rotate(-i) hull() for(j = [1, -1])
        translate([0, 0, sting_size + 5 * j - 3])
          linear_extrude(1) offset(1.5 * j)
            hull() {
              circle(r = sting_size / 2 + 3);
              translate([-50, 0, 0]) circle(r = 1.1);
          }
    }
    linear_extrude(sting_size / 4) difference() {
      intersection() {
        circle(50 + 5);
        translate([-100 + sting_size, 100 - sting_size, 0])
          square(200, center = true);
        rotate(-max([for(i = sting_angle) i]))
          translate([-100 + sting_size, -100 + 5, 0])
            square(200, center = true);
      }
    }
    difference() {
      intersection() {
        linear_extrude(73) difference() {
          intersection() {
            circle(50 + 5);
            translate([-100 + sting_size, 7 - sting_size, 0])
              square([200, 14], center = true);
            rotate(-max([for(i = sting_angle) i]))
              translate([-100 + sting_size, -100 + 5, 0])
                square(200, center = true);
          }
        }
        translate([-100, 0, 80]) rotate([-130, 0, 0])
          cube(200);
      }
      intersection() {
        linear_extrude(100) difference() {
          intersection() {
            circle(50 + 5 - 3);
            translate([
              -100 + sting_size,
              7 - sting_size + 3,
              0
            ]) square([200, 14], center = true);
            rotate(-max([for(i = sting_angle) i]))
              translate([-100 + sting_size, -100 + 5, 0])
                square([200 - 6, 200], center = true);
          }
        }
        translate([-100, 4, 80]) rotate([-130, 0, 0])
          cube(200);
      }
    }
    difference() {
      hull() {
        cylinder(
          h = sting_size - 2,
          r = (sting_size/2 - 4) * cos(180 / 8) - tolerance
        );
        cylinder(
          h = sting_size,
          r = (sting_size/2 - 4) * cos(180 / 8) - tolerance - 1
        );
      }
    }
  }
  translate([0, 0, 1]) linear_extrude(sting_size - 2)
    for(a = [0:60:179]) rotate(a) square([
      ((sting_size/2 - 4) * cos(180 / 8) - tolerance) * 2 - 3,
      .1
    ], center = true);
}