// Model to generate a simple, “blocky” file
// File name: BlockyMath.scad
function f(x, y) = ((x - 50) * (y - 50)) / 100 + 30;
xmax = 20;
ymax = 20;
increment = 1;
for(x = [0:increment:xmax], y = [0:increment:ymax]) translate([x, y, 0]) cube([increment + .001, increment + .001, f(x, y)]);