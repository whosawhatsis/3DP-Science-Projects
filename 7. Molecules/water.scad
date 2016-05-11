//Model to create a water molecule with connectors
// To create an ice lattice
// File water.scad
Od = 20;  //Oxygen atom diameter, mm
Hd = 10;  //Hydrogen atom diamter, mm
OHspacing = 10;  //Offset between centers of O and H atoms, mm
peg = 5;  //diameter of the peg , mm
tol = .2;    //Tolerance (empty space) between peg in hole and peg
peg_len = 10; // length of the peg

$fs = .5;
$fa = 2;

//pick angle of the structure; last one shown will be used by program
angle = acos(-1/3); //tetrahedral, ~109.5
angle = 104.5; //water


for(a = [0, 180]) rotate(a) translate([-9, 12.5, 0,]) rotate(angle / 2 - 90) half();

//Now create the half a moledule
module half() difference() {
  union() {
    sphere(Od/2);
    for(i = [-1, 1]) rotate(angle/2 * i) {
      translate([OHspacing, 0, 0]) sphere(Hd/2);
      rotate([0, 90, 0]) difference() {
        union() {
          cylinder(r = peg / 2, h = OHspacing + Hd/2 + peg_len);
          scale([5/6, 1, 1]) translate([0, 0, OHspacing + Hd/2 + peg_len]) hull()
            rotate_extrude(convexity = 5) translate([-peg / 3, 0, 0]) circle(peg / 4);
        }
        cube([peg * 2, peg/4, (OHspacing + Hd/2 + peg_len) * 3], center = true);
      }
    }
  }
  for(i = [-1, 1]) rotate([0, angle/2 * i - 90, 0])
    translate([0, 0, (peg + tol) * sin(angle) / 2 + (peg + tol)/4])
      rotate_extrude(convexity = 5) {
        hull() {
          translate([peg / 2, 0, 0]) circle(peg / 4 + tol);
          translate([0, -peg/4 - tol, 0]) square([tol, peg / 2 + tol * 2]);
        }
        square([peg / 2 + tol, Od]);
      }
  translate([0, 0, -100 + tol/2]) cube(200, center = true);
}
