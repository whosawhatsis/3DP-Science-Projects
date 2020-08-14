//OpenSCAD model to print out a NACA airfoil
// Formulation of NACA airfoil mathematics based on equations in 
// NACA Report 460, "The Characteristics of 78 Related Airfoil Sections 
// From Tests in the Variable-Density Wind Tunnel" (1935) by
// E.N. Jacobs, K.E. Ward and R.M. Pinkerton. 
// File airfoil.scad

NACA = 2412; //Airfoil to print - this is broken into abcd parameters below
chord = 60; // Chord length, mm
length = 120; //wing length, mm

taper = 1; // taper ratio: ratio of chord at root to chord at tip
sweep = 0; // if wing is swept , sweep angle in degrees ; if 0, no sweep


a = (NACA - NACA % 1000) / 100000;
b = (NACA % 1000 - NACA % 100) / 1000;
cd = NACA % 100;

echo("a", a);
echo("b", b);
echo("cd", cd);
if((taper == 1 || taper == 0) && sweep != 0) 
echo("ERROR: Sweep without taper is not currently supported!");

step = 1/500;

$fs = .5;
$fa = 2;

airfoil();

//Extract the wing parameters from the NACA number 
// and insert them in array p[]

function parameters(NACA) = [(NACA - NACA % 1000) / 100000, 
   (NACA % 1000 - NACA % 100) / 1000, NACA % 100];

//Develop the camber line,
function camber(x, p) = (
    (x < p[1]) ?
        p[0]/pow(p[1], 2)
    :
        p[0]/pow(1 - p[1], 2)
    ) * -pow(x - p[1], 2) + p[0];
//mirror camber
function camber_(x, p) = (
     (x < p[1]) ? 
        p[0]/pow(p[1], 2) * (2 * p[1] * x - pow(x, 2))
    :
        (p[0]/pow(1 - p[1], 2)
    ) * ((1 - 2 * p[1]) + 2 * p[1] * x - pow(x, 2)));

//Determine the thickness 
function thickness(x, p) = (p[2] / 20) * (0.29690 * sqrt(x) - 0.12600 * x -
    0.35160 * pow(x, 2) + 0.28430 * pow(x, 3) - 0.10150 * pow(x, 4));
    
 //Find instantaneous angle of slope of the camber curve, theta, 
// so that the thickness component can be
//computed perpendicular to the camber line

function theta(x, p) = 
    atan((p[0]/pow(((x < p[1]) ? p[1] : 1 - p[1]), 2) * (2 * p[1] - 2 * x)));

//Draw create the full airfoil from the cross-section by 
//extruding the cross-section 

module airfoil(
    p = parameters(NACA), chord = chord, length = length, taper = taper,
    sweep = sweep
) {
    translate([-chord / 2 * 0 + length * taper * tan(sweep) + chord / 4, 0, 0]) 
        linear_extrude(length, center = false, scale = 1/taper) 
            translate([-length * taper * tan(sweep) - chord/4, 0, 0])
                airfoil_cross_section(p, chord);
}

//Create the cross-section by hulling a series of rhomboids bisected by a tangent 
// to the camber line with a height equal to half the wing thickness 

// Original version described in the text (superseded below)
module airfoil_cross_section(p, chord)
    for(x_ = [step / 10:step:1 - step])
        hull() for(x = [x_, x_ + step]) {
            translate([x * chord, camber(x, p) * chord, 0]) rotate(theta(x, p))
                scale([chord * step / 10, thickness(x, p) * chord]) circle($fn = 4);
            translate([x * chord, camber_(x, p) * chord, 0]) rotate(theta(x, p))
                scale([chord * step / 2, chord * step / 2]) #%circle($fn = 4);
        }

// Optimized version
module airfoil_cross_section(p, chord) {
    polygon(concat(
        [for(x = [0:step:1]) chord * [x - thickness(x, p) * sin(theta(x, p)), camber(x, p) + thickness(x, p) * cos(theta(x, p))]], 
        [for(x = [1:-step:0]) chord * [x + thickness(x, p) * sin(theta(x, p)), camber(x, p) - thickness(x, p) * cos(theta(x, p))]]
    ));
}
//End of model
