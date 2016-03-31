// Model to generate a simple, “blocky” file
// File name: BlockyMath.scad
function f(x, y) = ((x - 50) * (y - 50)) / 100 + 30; xmax = 20;
ymax = 20;
for(x = [0:xmax], y = [0:ymax]) translate([x, y, 0]) cube([1.001, 1.001, f(x, y)]);


