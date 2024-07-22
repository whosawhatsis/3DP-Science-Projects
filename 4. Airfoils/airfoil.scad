//OpenSCAD model to print out a NACA airfoil
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

assert(
  !(taper == 1 && sweep),
  "ERROR: Sweep without taper is not currently supported!"
);

step = 1/200;

$fs = .5;
$fa = 2;

airfoil();

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

//Draw create the full airfoil from the cross-section by 
//extruding the cross-section 
module airfoil(
  p = parameters(NACA), chord = chord, length = length,
  taper = taper, sweep = sweep
) {
  translate([length * taper * tan(sweep) + chord / 4, 0, 0]) 
    linear_extrude(length, center = false, scale = taper) 
      translate([-length * taper * tan(sweep) - chord/4, 0, 0])
        airfoil_cross_section(p, chord);
}

//Create the cross-section by hulling a series of rhomboids
//bisected by a tangent to the camber line
//with heights equal to the wing thickness at that point
module airfoil_cross_section(p, chord)
  for(x_ = [0:step:1 - step])
    hull() for(x = [x_, x_ + step])
      translate([x * chord, camber(x, p) * chord, 0])
        rotate(theta(x, p))
          if(thickness(x, p))
            scale([chord * step / 10, thickness(x, p) * chord])
              circle($fn = 4);
          else circle(.00001, $fn = 4);