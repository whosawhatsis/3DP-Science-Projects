// OpenSCAD model to print out a pair of NACA airfoils 
// (to make a complete wing)
// Plus a support that can be used for measuring lift
// Formulation of NACA airfoil mathematics based on equations in 
// NACA Report 460, "The Characteristics of 78 Related Airfoil Sections 
// From Tests in the Variable-Density Wind Tunnel" (1935) 
// by E.N. Jacobs, K.E. Ward and R.M. Pinkerton. 
// File airfoilStand.scad

NACA = 2412; //Airfoil to print - this is broken into abcd parameters below
chord = 30; // Chord length, mm
length = 120; //wing length 

taper = 1; // taper ratio: ratio of chord at root to chord at tip
sweep = 0; // if wing is swept , sweep angle in degrees ; if 0, no sweep


sting_size = 20; // sting cross section in mm
sting_length = 100; // sting vertical and horizonal bar length, in mm

sting_angle = [0:5:25]; //range of angle of attack possible 

nest = false; //Attempt to nest parts for printing, may not fit with certain options

 
if((taper == 1 || taper == 0) && sweep != 0) echo("ERROR: Sweep without taper is not currently supported!");

step = 1/500;

$fs = .5;
$fa = 2;

airfoil_with_sting();
%mirror([0, 0, 1]) airfoil_with_sting();
%translate([chord * 1.5 + sting_size/4, -sting_length, -sting_size/2]) base();

if(nest) {
    translate([chord * 1.5 - sting_size / 2 - 20, -45, 0]) base();
    translate([chord * 1.5 - sting_size/2, sting_size, 0]) mirror([1, 0, 0]) airfoil_with_sting();
} else {
    translate([0, 50, 0]) base();
    translate([-5, 0, 0]) mirror([1, 0, 0]) airfoil_with_sting();
}



//Extract the wing parameters from the NACA number 
// and insert them in array p[]
function parameters(NACA) = [(NACA - NACA % 1000) / 100000,
    (NACA % 1000 - NACA % 100) / 1000, NACA % 100];

//Develop the camber line
function camber(x, p) = (
     (x < p[1]) ? 
        p[0]/pow(p[1], 2)
    :
        p[0]/pow(1 - p[1], 2)
    ) * -pow(x - p[1], 2) + p[0];

function camber_(x, p) = (
     (x < p[1]) ?
        p[0]/pow(p[1], 2) * (2 * p[1] * x - pow(x, 2))
    : 
         (p[0]/pow(1 - p[1], 2)
    ) * ((1 - 2 * p[1]) + 2 * p[1] * x - pow(x, 2)));

//Determine the thickness 
function thickness(x, p) = (p[2] / 20) * (0.29690 * sqrt(x) - 0.12600 * x
    -0.35160 * pow(x, 2) + 0.28430 * pow(x, 3) - 0.10150 * pow(x, 4));

//Find instantaneous angle of slope of the camber curve, theta, 
// so that the thickness component can be
//computed perpendicular to the camber line
function theta(x, p) = atan((p[0]/pow(((x < p[1]) ? p[1] : 1 - p[1]), 2) * (2 * p[1] - 2 * x)));

//Draw create the full airfoil from the cross-section by extruding the cross-section
module airfoil(
    p = parameters(NACA), chord = chord, length = length, taper = taper,
    sweep = sweep
) {
    translate([-chord / 2 * 0 + length * taper * tan(sweep) + chord / 4, 0, 0]) 
        linear_extrude(length, center = false, scale = 1/taper) 
            translate([-length * taper * tan(sweep) - chord/4, 0, 0])
                airfoil_cross_section(p, chord);
}

// Create the cross-section by hulling a series of rhomboids 
// centered on the camber line
// with a height equal to half the wing thickness 

module airfoil_cross_section(p, chord) for(x_ = [step / 10:step:1 - step])
    hull() for(x = [x_, x_ + step]) {
        translate([x * chord, camber(x, p) * chord, 0]) rotate(theta(x))
            scale([chord * step / 10, thickness(x, p) * chord]) circle($fn = 4);
        translate([x * chord, camber_(x, p) * chord, 0]) rotate(theta(x, p))
            scale([chord * step / 2, chord * step / 2]) %circle($fn = 4);
}


*translate([chord / 4, 0, 0]) rotate([0, sweep, 0]) %cube(100);

module airfoil_with_sting() translate([0, 0, 0]) union() {
    airfoil();
    hull() {
        translate([chord * parameters(NACA)[1], chord * parameters(NACA)[0], 0])
            intersection() {
                sphere(r = chord * thickness(parameters(NACA)[1], 
                    parameters(NACA)));
                    translate([0, 0, chord/2]) cube(chord, center = true);
            }
            translate([chord * 1.5 - sting_size/4, chord * parameters(NACA)[0], 0])
                intersection() {
                    rotate([0, -90, 0]) rotate_extrude() rotate(-90) intersection() {
                        airfoil_cross_section(parameters(0040), sting_size);
                        square(sting_size);
                    }
                    translate([0, 0, sting_size]) cube(sting_size * 2, center = true);
            }
        }
    difference() {
        translate([chord * 1.5 - sting_size/4, chord * parameters(NACA)[0], 0]) 
            rotate([90, 0, 0]) linear_extrude(sting_length) intersection() {
                airfoil_cross_section(parameters(0040), sting_size);
                square(sting_size);
        }
        translate([chord * 1.5 + sting_size/4, -sting_length, -1]) 
            cylinder(r = sting_size/2 - 3, h = sting_size);
    }
    translate([chord * 1.5 + sting_size/4, -sting_length, 0]) intersection() {
        rotate([-90, 0, 0]) rotate_extrude(convexity = 10) hull() {
            difference() {
                circle(r = sting_size / 2 + 1);
                translate([0, -50, 0]) square(100);
            }
            translate([-50, 0, 0]) circle(r = 1);
        }
        linear_extrude(sting_size / 4, convexity = 10) difference() {
            hull() {
                circle(r = sting_size / 2);
                translate([-50, 0, 0]) circle(r = 1);
            }
            circle(r = sting_size/2 - 4, $fn = 8);
        }
    }
}

module base() {
    difference() {
        linear_extrude(sting_size, convexity = 10) difference() {
            intersection() {
                circle(50 + 5);
                translate([-100 + sting_size, 100 - sting_size, 0])
                    square(200, center = true);
                rotate(-max([for(i = sting_angle) i]))
                    translate([-100 + sting_size, -100 + 5, 0]) square(200, center = true);
            }
            circle(50 - 2);
            for(i = sting_angle) rotate(-i) hull() {
                circle(r = sting_size / 2 + 3);
                translate([-50, 0, 0]) circle(r = 1.1);
            }
        }
        for(i = sting_angle) rotate(-i) hull() for(j = [1, -1])
            translate([0, 0, sting_size + 5 * j - 3]) linear_extrude(1) offset(1.5 * j)
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
            translate([-100, 0, 80]) rotate([-130, 0, 0]) cube(200);
        }
        intersection() {
            linear_extrude(100) difference() {
                intersection() {
                    circle(50 + 5 - 3);
                    translate([-100 + sting_size, 7 - sting_size + 3, 0]) 
                        square([200, 14], center = true);
                    rotate(-max([for(i = sting_angle) i])) 
                        translate([-100 + sting_size, -100 + 5, 0]) 
                            square([200 - 6, 200], center = true);
                }
            }
            translate([-100, 4, 80]) rotate([-130, 0, 0]) cube(200);
        }
    }
    hull() {
        cylinder(r = (sting_size/2 - 4) * cos(180 / 8) - .2, h = sting_size - 2);
        cylinder(r = (sting_size/2 - 4) * cos(180 / 8) - .2 - 1, h = sting_size);
    }
}
//End model
