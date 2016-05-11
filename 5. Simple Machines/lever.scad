// A model which creates all three classes of lever
// Percentage on either side of fulcrum printed on lever
// Designed to be printed on its side 
// File lever.scad

lever = [70, 30]; //Length of the on either side of the fulcrum (class 1) or
                  // load or resistance application point (class 2/3)
class = 1; //class of lever 
fulcrum_height = 30; //height of point of fulcrum, in mm
width = 30;  //width in mm


linear_extrude(width, convexity = 5) difference() {
	intersection() {
		square(fulcrum_height * 2, center = true);
		rotate(-135) square(fulcrum_height * sqrt(2));
	}
	difference() {
		square(fulcrum_height * 2 - 10, center = true);
		intersection_for(a = [1, -1]) 
                                         rotate(-135 + a * (45 - 15)) square(fulcrum_height * sqrt(2));
	}
}

difference() {
	linear_extrude(width, convexity = 5) difference() {
		translate([-5 - ((class == 1) ? lever[1] : 0), 0, 0]) 
                                                square([10 + lever[0] + lever[1], 5]);
		translate([0, 2.5, 0]) rotate(-135) square(5);
		translate([lever[0], 2.5, 0]) rotate(((class == 3) ? -135 : 45)) square(5);
		translate([((class == 1) ? -lever[1] : lever[0] + lever[1]), 2.5, 0]) 
                                    rotate(((class == 2) ? -135 : 45)) square(5);
		
	}
	translate([lever[0] / 2, 5, width / 2])
		rotate([90, 0, 180])
			linear_extrude(height = 1, center = true, convexity = 5) 
				text(str(lever[0]), size = min(width / 3, lever[0] / 3), 
                                                                         halign = "center", valign = "center");
	translate([(class == 1) ? -lever[1] / 2 : lever[0] + lever[1] / 2, 5, width / 2])
		rotate([90, 0, 180])
			linear_extrude(height = 1, center = true, convexity = 5) 
				text(str(lever[1]), size = min(width / 3, lever[1] / 3), 
                                                                         halign = "center", valign = "center");
}
