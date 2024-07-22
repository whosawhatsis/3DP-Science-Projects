//OpenSCAD model to create an archimedes screw
//File archimedesScrew.scad
//(c) 2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//how far up the screw steps with each turn (mm)
pitch = 16;
//radius of the screw (mm)
r = 12;
//wall thickness, ideally double your nozzle diameter (mm)
wall = .8;
//number of turns
turns = 5;
//number of segments per turn
fn = 180;

$fs = .2;
$fa = 2;

rawthread = [
  r * [0.01, sin(-45) * 2],
  for(a = [-45:2:45]) r * [cos(a), sin(a)],
  for(a = [45:-2:-45]) (r - wall) * [cos(a), sin(a)],
  r * [0.01, sin(-45)],
];

%polygon(rawthread);

points = [for(a = [0:360 / fn:turns * 360]) 
  for(slice = rawthread) [
    slice[0] * sin(a),
    slice[0] * cos(a),
    a * pitch / 360 + slice[1]
  ]
];

*for(i = points) translate(i) cube(.2, center = true);

translate([0, 0, r * sin(45) * 2]) polyhedron(points, [
  for(i = [0:len(rawthread) / 2 - 2])
    [i, i + 1, len(rawthread) - 1 - i],
  for(i = [0:len(rawthread) / 2 - 2])
    [i + 1, len(rawthread) - 2 - i, len(rawthread) - 1 - i],
  for(i = [0:len(rawthread) / 2 - 2])
    [i + 1, i, len(rawthread) - 1 - i]
      + [
        len(points) - len(rawthread),
        len(points) - len(rawthread),
        len(points) - len(rawthread)
      ],
  for(i = [0:len(rawthread) / 2 - 2])
    [i + 1, len(rawthread) - 1 - i, len(rawthread) - 2 - i]
      + [
        len(points) - len(rawthread),
        len(points) - len(rawthread),
        len(points) - len(rawthread)
      ],
  for(i = [0:len(points) - len(rawthread) - 1])
    [i + 1, i, i + len(rawthread)],
  for(i = [0:len(points) - len(rawthread) - 1])
    [i, i + len(rawthread) - 1, i + len(rawthread)],
]);

cylinder(r = r, h = r / sqrt(2) + wall);
cylinder(r = r * .02, h = r / sqrt(2) + pitch * turns);