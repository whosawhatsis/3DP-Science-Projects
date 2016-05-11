// A model which creates pulleys and wheels on a holder
// Makes one piece for the backbone/hub, then a pulley or wheel 
// and a clip to hold each pulley or wheel
// Designed to be printed in several pieces and then assembled
// File pulleysWheels.scad

wheel = false; //wheels = false gives you pulleys
clearance = .4; //spacing between hub and wheel/pulley, mm
pulley_width = 8; // rim, in mm
wheel_width = 20; // rim, in mm - must be greater than min_diameter
spacing = 3; //space between wheel rims or pulley
loop = 8; //diameter of the loop on one side the the hook on the other, mm
count = 2; // number of pulleys (ignored for wheels)
min_diameter = 20; // minimum acceptable size of pulley or wheels, mm
diameter_step = 5; // how much bigger to make each pulley when doing multiples, mm
csec_d = 5; //cross-sectional diameter of pulley frame, mm	

$fs = .5; //OpenSCAD facet controls
$fa = 2;//OpenSCAD facet controls

width = wheel ? wheel_width : pulley_width;
diameter = wheel ? [min_diameter, min_diameter] : [for(x = [0:count - 1]) min_diameter + (count - x - 1) * diameter_step];

if(wheel) {
	%for(i = [0:len(diameter) - 1], j = [0, 1], d = diameter[i]) mirror([j, 0, 0]) translate([-width/2, center_offset(i), csec_d / 2 * sin(45)]) rotate([0, 90, 0]) wheel(d);
	for(i = [0:len(diameter) - 1], j = [0, 1], d = diameter[i]) translate([j * -(diameter[i] + 1) - diameter[i]/2 - width/2 - csec_d - spacing - 1, center_offset(i), 0]) wheel(d);
} else {
	%for(i = [0:len(diameter) - 1], d = diameter[i]) translate([-width/2, center_offset(i),
                    csec_d / 2 * sin(45)]) rotate([0, 90, 0]) pulley(d);
	for(i = [0:len(diameter) - 1], d = diameter[i]) translate([-diameter[i]/2 - width/2 - csec_d - 
                      spacing - 1, center_offset(i), 0]) pulley(d);
}
	
//create pulley
module pulley(d) difference() {
	rotate_extrude() difference() {
		square([(d + spacing)/2 - clearance, width - clearance * 2 + 1]);
		difference() {
			translate([d/2 + width/2, width/2 - clearance + 1, 0]) 
                                                                       circle(width / sin(45) / 2);
			square([(d + spacing)/2, 1]);
		}
	}
	cylinder(r = (csec_d / 2 + clearance) / cos(180 / 8), h = width * 3, center = true, $fn = 8);
}

//create wheel
module wheel(d) difference() {
	union() {
		cylinder(r = d/2, h = 3);
		cylinder(r = (csec_d / 2 + clearance + 3) / cos(180 / 8), h = width / 2 + .5 - clearance * 1.5, $fn = 8);
	}
	cylinder(r = (csec_d / 2 + clearance) / cos(180 / 8), h = width * 3, center = true, $fn = 8);
}

module csec(d = csec_d) translate([0, d/2 * sin(45), 0]) intersection() {
	circle(d/2);
	square([d, d * sin(45)], center = true);
}

module straight(l = 10, center = true, ends = true) {
	rotate([90, 0, 180]) linear_extrude(height = l, center = center, convexity = 5) csec();
	if(ends) for(b = center ? [l/2, -l/2] : [0, l]) translate([0, b, 0]) arc(0);
}

module arc(r = 10, a = 360, ends = true) union() {
	intersection() {
		linear_extrude(height = csec_d, convexity = 5) {
			if(a < 90) intersection_for(b = [0, a - 90]) rotate(b) square(r + csec_d);
			else for(b = [0:45:a]) rotate(min(b, a - 90)) square(r + csec_d);
		}
		rotate_extrude(convexity = 5) intersection() {
			translate([r, 0, 0]) csec();
			square(r + csec_d);
		}
	}
	if(a < 360 && ends) for(b = [0, a]) rotate(b) translate([r, 0, 0]) arc(0);
}

function center_offset(n) = (n == 0) ? 0 : [for(i = [0:n - 1]) diameter[i]/2 + spacing + diameter[i+1]/2] * [for(i = [0:n - 1]) 1];

//create snap rings to retain wheels/pulleys
for(i = [0:len(diameter) - 1]) translate([(width + csec_d) / 2 - csec_d * 1.5, 
             center_offset(i) - csec_d * 1.5 - 1, 0]) linear_extrude(2) difference() {
	circle(csec_d);
	rotate(180 / 8) circle((csec_d / 2 * sin(45) + clearance / 2) / cos(180 / 8), $fn = 8);
	translate([0, -csec_d/2 - csec_d * sin(45) / 2 - 2, 0]) square([csec_d * 2, csec_d], center = true);
	translate([0, csec_d, 0]) square([csec_d * sin(45) * .9, csec_d * 2], center = true);
	translate([0, csec_d * 1.2, 0]) scale([1, 2, 1]) rotate(45) square(csec_d, center = true);
}

//create backbone and axles
translate([(width + csec_d) / 2 + 1, -diameter[0]/2, 0]) 
	straight(diameter[0]/2 + center_offset(len(diameter) - 1) + diameter[len(diameter) - 1]/2, false);
for(i = [0:len(diameter) - 1]) translate([(width + csec_d) / 2 + 1, center_offset(i), 0]) rotate(90) {
	difference() {
		straight(width + csec_d + clearance + 2, center = false);
		translate([0, ((width + csec_d) / 2 + 1 + clearance) + width/2, csec_d / 2 * sin(45)]) rotate([-90, 0, 0]) linear_extrude(2 + clearance * 2) difference() {
			circle(csec_d);
			circle(csec_d / 2 * sin(45));
		}
	}
	rotate([90, 0, 180]) linear_extrude(height = csec_d / 2 + clearance, center = false, 
           convexity = 5) translate([0, csec_d/2 * sin(45), 0]) intersection() {
		circle(csec_d/2 + 1);
		square([csec_d + 2, csec_d * sin(45)], center = true);
	}
}

// create the end loop and hook
for(i = [0, 1]) mirror([0, i, 0]) translate([0, i ? diameter[0] / 2 : center_offset(len(diameter) - 1) +
                                                          diameter[len(diameter) - 1]/2, 0]) {
	arc((width + csec_d)/2 + 1, 90);
	
	translate([0, width / 2 + csec_d + 1 + loop/2, 0]) rotate(30) 
                                         arc(csec_d/2 + loop/2, i ? 240 : 360);
}

