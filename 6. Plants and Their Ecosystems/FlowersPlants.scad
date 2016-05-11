// a modified Archimedes spiral
// Rich "Whosawhatsis" Cameron, February 21, 2016
// This work is licensed under a
// Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
// 
length = 30; //base petal length (will be modified), mm
width = 3; //base width, mm
thickness = .1; //base thickness, percentage
pointiness = .1; //should be between 0 and 1 - pointier leaves have higher value
curvature = 0.2; //makes the petals bend more
shorten = 15; //makes the petals get shorter from the center out
petals = 89; //needs to be a Fibbonacci number (1,2,3,5,8,13,21,34,55,89...)
petalSpacing = .2; //radial offset of each petal (cumulative)OpenSCAD program to create plants and flowers in 
openness = .1; //angle of each petal (cumulative)
petalOffset = 21; //skip this many petals in the center, creates an open space and flatter flower
tip = 0; //diameter of tip
minbase = 20; //minimum base diameter in mm -increase if your base is too small

zseg = 20; //vertical segments, more = smoother, but longer rendering
xseg = 10; //horizontal segments, more = smoother, but longer rendering

goldenAngle = 137.508; //constant, should never change


function chord(z) = max(tip / width / 2, sqrt(z) * sqrt(1 - z) * 4 * pow(1 - z * pointiness, 2) *
	pow(1 / pointiness, 1/3));
function camber(x, a = .5, b = 1) = a * (cos(x * 180 * b) + 1) / 2;
function theta(x, a = .5, b = 1) = a * -sin(x * 180 * b) * 60;
function thickness(x, a = 1, b = thickness) = a * pow(x + 1, 2) * pow(x - 1, 2) / 10 +
	b * (sqrt(1 + x) + sqrt(1 - x) - 1);

$fs = .5;
$fa = 2;

function quad(a, b, c, d, r = false) = r ? [[a, b, c], [c, d, a]] : [[c, b, a], [a, d, c]]; //create triangles from quad

function points(roll = 2) = concat([for(i = [for(z = [for(z = [0:zseg]) z / zseg])
	concat(
		[for(
			x = [for(i = [-xseg:xseg]) i / xseg],
			a = chord(z) * (x + thickness(x) * sin(theta(x, .1, chord(z) / 2))),
			r = max(.1, 
				(chord(z) * (camber(x, .1, chord(z) / 2) - thickness(x)) *
					cos(theta(x, .1, chord(z) / 2))) + roll + curvature * pow(z * roll, 2)
			)
		) [
			(sin(min(max(a * 180 / PI / r, -179), 179))) * r,
			(cos(min(max(a * 180 / PI / r, -179), 179))) * r - roll,
			z
		]],
		[for(
			x = [for(i = [-xseg:xseg]) i / xseg],
			a = chord(z) * (-x + thickness(x) * sin(theta(x, .1, chord(z) / 2))),
			r = max(.1, 
				(chord(z) * (camber(x, .1, chord(z) / 2) + thickness(x)) *
					cos(theta(x, .1, chord(z) / 2))) + roll + curvature * pow(z * roll, 2)
			)
		) [
			(sin(min(max(a * 180 / PI / r, -179), 179))) * r,
			(cos(min(max(a * 180 / PI / r, -179), 179))) * r - roll,
			z
		]]
	)
], j = i) j]);

faces = concat(
	[for(i = [for(x = [0:xseg * 2], xmax = xseg * 4 + 1)
		quad(
			x,
			x + 1,
			xmax - x - 1,
			xmax - x,
			true
		)], v = i) v],
	[for(i = [for(z = [0:zseg - 1], x = [0:xseg * 4 + 1], xmax = xseg * 4 + 2)
		quad(
			z * xmax + x,
			z * xmax + x + xmax,
			z * xmax + x + (((x % xmax) == xmax - 1) ? 0 : xmax) + 1,
			z * xmax + x + (((x % xmax) == xmax - 1) ? -xmax : 0) + 1,
			true
		)], v = i) v],
	[for(i = [for(x = [0:xseg * 2], xmax = xseg * 4 + 1)
		quad(
			len(points()) - 1 - (x),
			len(points()) - 1 - (x + 1),
			len(points()) - 1 - (xmax - x - 1),
			len(points()) - 1 - (xmax - x),
			true
		)], v = i) v]
);
 
for(petal = [petalOffset:petalOffset + petals - 1]) rotate([0, 0, petal * goldenAngle])
	translate([0, petal * petalSpacing, 0]) rotate([-petal * openness, 0, 0]) scale([
		width,
		width,
		length * (1 - pow(petal * openness * curvature * shorten / 100, 3))
	]) polyhedron(points(petal * petalSpacing / width), faces);

translate([0, 0, -width / 2]) 
	scale(max(minbase, ((petalOffset + petals) * petalSpacing + width)) / 50) intersection() {
		scale([1, 1, .5]) sphere(50);
		translate([0, 0, 50]) cube(100, center = true);
	}