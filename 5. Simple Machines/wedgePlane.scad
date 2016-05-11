// A model which creates both a wedge and an inclined plane 
// File wedgePlane.scad

length = 100;  // length of longest side in mm
angle = 30; // angle of the plane or wedge, in degrees 
width = 50; // length of one side of the triangle (height inclined plane, max width wedge)

wedge(length, width, angle);
translate([0, -length * tan(angle) - 5, 0]) inclined_plane(length, width, angle);

module wedge(length = 100, width = 50, angle = 30, isoceles = true) difference() {
	linear_extrude(width, convexity = 5) intersection() {
		square([length, length * tan(angle)]);
		rotate(angle - 90) square([length * sin(angle), length / cos(angle)]);
		if(isoceles) rotate(angle / 2 - 90)
			translate([-length * sin(angle / 2), 0, 0])
				square([length * sin(angle / 2) * 2, length * cos(angle / 2)]);
	}
	if(isoceles) translate([length, 0, width / 2])
		rotate([0, 90, angle / 2])
			translate([0, length * sin(angle / 2), 0])
				linear_extrude(height = 1, center = true, convexity = 5) 
					text(str(angle, "°"), size = min(width / 3, length * sin(angle / 2)), halign = "center", valign = "center");
	else translate([length, length * tan(angle) / 2, width / 2])
		rotate([0, 90, 0])
			linear_extrude(height = 1, center = true, convexity = 5) 
				text(str(angle, "°"), size = min(width / 3, length * tan(angle) / 2), halign = "center", valign = "center");
}

module inclined_plane(length = 100, width = 50, angle = 30)
	wedge(length = length, width = width, angle = angle, isoceles = false);
