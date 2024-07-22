//OpenSCAD model to print out an arbitrary surface, z = f(x,y)
//Either prints the surface two-sided with t = thickness
//Or if t = 0, prints a top surface with a flat bottom
//File oneSlit.scad
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Based on triangleMeshSurface.scad
//from github.com/whosawhatsis/Calculus
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//Thickness along z axis. t = 0 gives a flat base at z = 0
t = 0;
//Range of [x, y] values to graph
range = [100, 100];
//resolution in mm (smaller = smoother, but slower render)
res = .25;
blockymode = false;

//wavelength, same units as slit
lambda = 4;
//width of slit
slit = 8;
//center of slit
c = 50;
//scaling factor, for visibility
factor = 20;
function sinetheta(x, y) = (x - c) / sqrt((x - c)^2 + y^2);
function slit_sinc(x, y) = lambda *
  sin(180 * sinetheta(x, y) * slit / lambda) /
  (PI * slit * sinetheta(x, y));
function f(x,y) = factor * pow(slit_sinc(x, y), 2) + 2;
//This function is now the SINGLE-slit experiment.
//sinc squared of (slit * pi * sin(theta)/lambda)

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