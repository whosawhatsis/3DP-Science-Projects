//OpenSCAD model of a truss with spring members
//File 2dTruss.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//thickness of the truss members, mm
beam_width = 3;
//Max length of the truss, mm
beam_length = 50;
//Width of the spring
spring_width = 15;
//Thickness of the spring members in x/y, mm
spring_thick = 1;
//Gap between turns of the spring
spring_gap = 3.3;
//number of turns in the springy part of each member
spring_turns = 9; 
//depth of the truss in the “third dimension”
plane_thick = 20;
//height of the feet on the ends of the truss, mm
foot = 10;
//number of triangles in the truss (should be an odd number)
triangles = 5; //[1:2:15]

$fs = .2;
$fa = 2;
spring_pos = (spring_width + spring_thick + spring_gap) * 2 / 3;

//Extrude the 2D truss by plane_thick mm
linear_extrude(plane_thick) {
  for(i = [0:triangles - 1])
    translate(beam_length * [i / 2, (i % 2) * sqrt(3) / 2, 0])
      beam();
  for(i = [0:triangles])
    translate(beam_length * [i / 2, (i % 2) * sqrt(3) / 2, 0])
      rotate(60 * ((i % 2) ? -1 : 1))
        beam();
  for(i = [0, triangles + 1]) hull() for(j = [0, 1])
    translate([i * beam_length / 2, -foot * j, 0])
      circle(beam_width * 1.5);
}

//Create a truss beam using a spring
module beam(l = beam_length, w = beam_width) {
  spring((
    l - (spring_gap + spring_thick) * (spring_turns + 1)) / 2
  ) offset(w / 2) square([l, .01]);
  for(i = [0, 1]) translate([i * beam_length, 0, 0])
    circle(beam_width * 1.5);
}

//Create a spring for the truss beams
module spring(
  p = 0,
  w = spring_width,
  t = spring_thick,
  g = spring_gap,
  s = spring_turns
) {
  difference() {
    union() {
      if($children) for(i = [0: $children - 1]) children(i);
      for(i = [0:s]) translate([(i + .5) * (g + t) + p, 0, 0])
        mirror([0, i % 2, 0])
          difference() {
            translate([-.005, 0, 0]) offset(g / 2 + t)
              square([
                .01,
                (w / 2 - g / 2 - t) * 
                  sin((i + .5) / (s + 1) * 180)
              ]);
            translate([0, -g - t, 0])
              square((g + t) * 2, center = true);
          }
    }
    for(i = [0:s]) mirror([0, i % 2, 0])
      translate([(i + .5) * (g + t) + p, 0, 0]) {
        translate([0, -w, 0]) offset(g / 2)
          square([
            .01,
            ((w / 2 - g / 2 - t) *
              sin((i + .5) / (s + 1) * 180) + w) * 2
          ], center = true);
        difference() {
          translate([0, -g - t, 0])
            square((g + t) * 2, center = true);
          for(j = [1, -1]) mirror([0, 1, 0])
            translate([j * (g + t), -w, 0]) offset(g / 2 + t)
              square([
                .01,
                w - g - t * 2 + w * 2
              ], center = true);
        }
      }
  }
}