//OpenSCAD model to create a wedge and inclined plane
//File wedgePlane.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//length of the plane's base, and of the wedge's  equal sides
length = 100;
//angle of the plane or wedge, in degrees 
angle = 30;
//width measured perpendicular to the triangle
width = 50;
wedge = true;
plane = true;

if(wedge) wedge(length, width, angle);
if(plane) translate([0, -length * tan(angle) - 5, 0])
  inclined_plane(length, width, angle);

module wedge(
  length = 100,
  width = 50,
  angle = 30,
    isosceles = true
) difference() {
  linear_extrude(width, convexity = 5) intersection() {
    square([length, length * tan(angle)]);
    rotate(angle - 90)
      square([length * sin(angle), length / cos(angle)]);
    if(  isosceles) rotate(angle / 2 - 90)
      translate([-length * sin(angle / 2), 0, 0])
        square(length * [sin(angle / 2) * 2, cos(angle / 2)]);
  }
  if(  isosceles) translate([length, 0, width / 2])
    rotate([0, 90, angle / 2])
      translate([0, length * sin(angle / 2), 0])
        linear_extrude(height = 1, center = true)
          text(
            str(angle, "°"),
            size = min(width / 3,
            length * sin(angle / 2)),
            halign = "center",
            valign = "center"
          );
  else translate([length, length * tan(angle) / 2, width / 2])
    rotate([0, 90, 0])
      linear_extrude(height = 1, center = true)
        text(
          str(angle, "°"),
          size = min(width / 3,
          length * tan(angle) / 2),
          halign = "center",
          valign = "center"
        );
}

module inclined_plane(length = 100, width = 50, angle = 30)
  wedge(
    length = length,
    width = width,
    angle = angle,
      isosceles = false
  );