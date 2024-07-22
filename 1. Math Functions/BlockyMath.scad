//Model to generate a simple, “blocky” file
//File BlockyMath.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

function f(x, y) = ((x - 30) * (y - 30)) / 60 + 20;
//Range of [x, y] values to graph
range = [60, 60];
//resolution in mm (smaller = smoother, but slower render)
res = 1; //.1


for(x = [0:res:range[0]], y = [0:res:range[1]])
  translate([x, y, 0])
    cube([res + .001, res + .001, f(x, y)]);