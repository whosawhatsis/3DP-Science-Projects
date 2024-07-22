//OpenSCAD model to compute gravitational potential wells
//File gravity.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Based on triangleMeshSurface.scad
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//Thickness along z axis. t = 0 gives a flat base at z = 0
t = 0;
//Range of [x, y] values to graph
range = [50, 100];
//resolution in mm (smaller = smoother, but slower render)
res = .25;
blockymode = false;
//which system to represent
system = "EarthMoon"; //["EarthMoon", "Algol"]
//EarthMoon is a 2-body system, and Algol is a 3-body system.
//To represent a different system, you can modify the values
//below for one of these cases, or modify the f(x, y) function.

//z height of printed model, in mm
model_height = 100;
AU_to_mm = .036;
//AU_to_mm = .001;
zscale = 4; //here just a scaling factor in Z

mass_earth = 5970; //in 10^21 kg
mass_moon = 72; //in 10^21 kg

mass_Aa1 = 4.5; //masses relative to Aa2
mass_Aa2 = 1;
mass_Ab = 2.5;
a1_a2 = 0.062; //distance in AU
a1_b = 2.69; //distance in AU (approximate)
//This model assumes that the three bodies are aligned
//with Aa2 between Aa1 and Ab.
  
function f(x, y) = (system == "EarthMoon") ?
  max(0, model_height - .2 * (
    mass_earth /
      sqrt(pow(x, 2) + pow(y - 82.3, 2)) +
    mass_moon /
      sqrt(pow(x, 2) + pow(y - 5.5, 2))
  ))
: (system == "Algol") ?
  max(0,  model_height - zscale * (
    mass_Aa1 /
      sqrt(pow(x, 2) + pow(y - 15, 2)) +
    mass_Aa2 /
      sqrt(pow(x, 2) + pow(y - 15 - a1_a2 / AU_to_mm, 2)) +
    mass_Ab /
      sqrt(pow(x, 2) + pow(y - 15 - a1_b / AU_to_mm, 2))
  ))
: "Undefined system!";

assert(is_num(f(0, 0)), "Undefined system!");

s = [
  round((range[0] - res/2) / res),
  round(range[1] / res * 2 / sqrt(3))
];
seg = [range[0] / (s[0] - .5), range[1] / s[1]];

function r(x, y, cx = range[0]/2, cy = range[1]/2) =
  sqrt(pow(cx - x, 2) + pow(cy - y, 2));
function theta(x, y, cx = range[0]/2, cy = range[1]/2) =
  atan2((cy - y), (cx - x));
function zeronan(n) = (n == n) ? n : 0;

points = concat(
  [for(y = [0:s[1]], x = [0:s[0]]) [
    seg[0] * min(max(x - (y % 2) * .5, 0), s[0] - .5),
    seg[1] * y,
    zeronan(
      f(
        seg[0] * min(max(x - (y % 2) * .5, 0), s[0] - .5),
        seg[1] * y
      )
    )
  ]], [for(y = [0:s[1]], x = [0:s[0]]) [
    seg[0] * min(max(x - (y % 2) * .5, 0), s[0] - .5),
    seg[1] * y,
    t ? zeronan(
      f(
        seg[0] * min(max(x - (y % 2) * .5, 0), s[0] - .5),
        seg[1] * y
      )
    ) - t : 0
  ]]
);
*for(i = points) translate(i) cube(.1, center = true);
  
function order(point, reverse) = [
  for(i = [0:2]) point[reverse ? 2 - i : i]
];
function mirror(points, offset) = [
  for(i = [0, 1], point = points)
    order(
      point + (i ? [0, 0, 0] : [offset, offset, offset]),
      i
    )
];

polys = concat(
  mirror(concat([
    for(x = [0:s[0] - 1], y = [0:s[1] - 1]) [
      x + (s[0] + 1) * y,
      x + 1 + (s[0] + 1) * y,
      x + 1 - (y % 2) + (s[0] + 1) * (y + 1)
    ]
  ], [
    for(x = [0:s[0] - 1], y = [0:s[1] - 1]) [
      x + (y % 2) + (s[0] + 1) * y,
      x + 1 + (s[0] + 1) * (y + 1),
      x + (s[0] + 1) * (y + 1)
    ]
  ]), len(points) / 2),
  mirror([for(x = [0:s[0] - 1], i = [0, 1]) order([
    x + (i ? 0 : 1 + len(points) / 2),
    x + 1,
    x + len(points) / 2
  ], i)], len(points) / 2 - s[0] - 1),
  mirror([for(y = [0:s[1] - 1], i = [0, 1]) order([
    y * (s[0] + 1) + (i ? 0 : (s[0] + 1) + len(points) / 2),
    y * (s[0] + 1) + (s[0] + 1),
    y * (s[0] + 1) + len(points) / 2
  ], 1 - i)], s[0])
);

if(blockymode)
  for(x = [0:res:range[0]], y = [0:res:range[1]])
    translate([x, y, 0]) cube([res, res, f(x, y)]);
else polyhedron(points, polys, convexity = 5);