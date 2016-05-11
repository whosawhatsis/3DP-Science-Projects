// OpenSCAD model to print out a 2D truss
// File name: 2DTruss.scad
// Program creates a 2D truss with members made of simulated springs

beam_width = 3; //thickness of the truss members, mm 
beam_length = 50; //Max length of the truss,mm
spring_width = 15; // Width of the spring
spring_thick = 1; //How thick (in the x-y plane) the members in the turn of the spring are, mm
spring_gap = 3.3;// Gap between turns of the spring
spring_turns = 9; // number of turns in the springy part of each member
spring_pos = (spring_width + spring_thick + spring_gap) * 2/3;
plane_thick = 20; // depth of the truss in the “third dimension”

triangles = 5; //number of triangles in the truss (should be an odd number)

$fs = .5;
$fa = 2;

// Take the 2D truss and extrude it for plane_thick mm to create the third dimension
linear_extrude(plane_thick) {
  for(i = [0:triangles - 1])
    translate([i * beam_length / 2, (i % 2) * beam_length * sqrt(3)/2, 0])
      beam();
  for(i = [0:triangles])
    translate([i * beam_length / 2, (i % 2) * beam_length * sqrt(3)/2, 0])
      rotate(60 * ((i % 2) ? -1 : 1))
        beam();
}

//Create the truss members with the “spring” inserted in mid-member
module beam(l = beam_length, w = beam_width) {
  spring(l / 2 - (spring_gap + spring_thick) * (spring_turns + 1) / 2)
    offset(w/2) square([l, .01]);
  for(i = [0, 1]) translate([i * beam_length, 0, 0]) circle(beam_width * 1.5);
}

//create the springs in each member by wrapping a curve around a set spacing
module spring(p = 0, w = spring_width, t = spring_thick, g = spring_gap, s = spring_turns) {
  difference() {
    union() {
      if($children) for(i = [0: $children - 1]) children(i);
      for(i = [0:s]) translate([(i + .5) * (g + t) + p, 0, 0]) mirror([0, i % 2, 0])
        difference() {
          translate([-.005, 0, 0]) offset(g/2 + t)
            square([.01, (w/2 - g/2 - t) * sin((i + .5)/(s + 1) * 180)]);
          translate([0, -g - t, 0])
            square((g + t) * 2, center = true);
        }
    }
    for(i = [0:s]) mirror([0, i % 2, 0]) translate([(i + .5) * (g + t) + p, 0, 0]) {
      translate([0, -w, 0]) offset(g/2)
        square([.01, (w/2 - g/2 - t) * sin((i + .5)/(s + 1) * 180) * 2 + w * 2], center = true);
      difference() {
        translate([0, -g - t, 0])
          square((g + t) * 2, center = true);
        for(j = [1, -1]) mirror([0, 1, 0]) translate([j * (g + t), -w, 0]) offset(g/2 + t)
          square([.01, w - g - t * 2 + w * 2], center = true);
      }
    }
  }
} 
