//OpenSCAD program to create plants and flowers in 
//a modified Archimedes spiral
//(c) 2016-2024 Rich Cameron
//for the book 3D Printed Science projects, Volume 1
//Licensed under a Creative Commons, Attribution,
//CC-BY 4.0 international license, per
//https://creativecommons.org/licenses/by/4.0/
//Attribute to Rich Cameron, at
//repository github.com/whosawhatsis/3DP-Science-Projects

//presets override the settings in the next section
preset = 0; // [0:"", 1:aloe, 2:daisy, 3:camellia, 4:jungle]
/*[custom plant settings]*/
//base petal length (will be modified), mm
length = 50;
//base width, mm
width = 6;
//base thickness, percentage
thickness = .3;
//should be between 0 and 1 - pointier leaves have higher value
pointiness = .5;
//makes the _petals bend more
curvature = 1.5;
//makes the petals get shorter from the center out
shorten = 6;
//needs to be a Fibonacci number
petals = 21; // [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
//radial offset of each petal (cumulative)
petalSpacing = .4;
//angle of each petal (cumulative)
openness = .2;
//skip petals in center, creates open space and flatter flower
petalOffset = 15;
//diameter of tip
tip = 0;

/*[other settings]*/
//mm, increase if your base is too small
minbase = 20;
//vertical segments, more = smoother, but longer rendering
zseg = 20;
//horizontal segments, more = smoother, but longer rendering
xseg = 10;

{} // end customizer

goldenAngle = 137.508; //constant, should never change

presets = [[],
  // l, w,  t,  p,   c,   s,  p, pS,  o, pO, t
  [ 50, 6, .3, .5,   1,   3, 34, .4, .2, 10, 0],
  [ 50, 3, .3, .2, .25, .25, 21, .4, .9, 30, 0],
  [ 30, 3, .1, .1,  .2,  15, 89, .2, .1, 21, 0],
  [120, 3,  1,  1,   3, 6.5,  8, .2, .2, 13, 3],
];

_length = preset ? presets[preset][0] : length;
_width = preset ? presets[preset][1] : width;
_thickness = preset ? presets[preset][2] : thickness;
_pointiness = preset ? presets[preset][3] : pointiness;
_curvature = preset ? presets[preset][4] : curvature;
_shorten = preset ? presets[preset][5] : shorten;
_petals = preset ? presets[preset][6] : petals;
_petalSpacing = preset ? presets[preset][7] : petalSpacing;
_openness = preset ? presets[preset][8] : openness;
_petalOffset = preset ? presets[preset][9] : petalOffset;
_tip = preset ? presets[preset][10] : tip;

function chord(z) = max(
  _tip / _width / 2,
  sqrt(z) * sqrt(1 - z) * 4 * pow(1 - z * _pointiness, 2) *
    pow(1 / _pointiness, 1/3)
);
function camber(x, a = .5, b = 1) = a * (cos(x * 180 * b) + 1)
  / 2;
function theta(x, a = .5, b = 1) = a * -sin(x * 180 * b) * 60;
function _thickness(x, a = 1, b = _thickness) = a * 
  pow(x + 1, 2) * pow(x - 1, 2) / 10 + 
  b * (sqrt(1 + x) + sqrt(1 - x) - 1);

$fs = .5;
$fa = 2;

//create triangles from quad
function quad(a, b, c, d, r = false) = r ? 
  [[a, b, c], [c, d, a]]
:
  [[c, b, a], [a, d, c]]
;

function points(roll = 2) = concat(
  [for(i = [for(z = [for(z = [0:zseg]) z / zseg])
    concat(
      [for(
        x = [for(i = [-xseg:xseg]) i / xseg],
        a = chord(z) * (x + _thickness(x) *
          sin(theta(x, .1, chord(z) / 2))),
        r = max(
          .1, 
          ((camber(x, .1, chord(z) / 2) - _thickness(x)) *
            chord(z) * cos(theta(x, .1, chord(z) / 2))) + 
            roll + _curvature * pow(z * roll, 2)
        )
      ) [
        (sin(min(max(a * 180 / PI / r, -179), 179))) * r,
        (cos(min(max(a * 180 / PI / r, -179), 179))) * r -
          roll,
        z
      ]],
      [for(
        x = [for(i = [-xseg:xseg]) i / xseg],
        a = chord(z) * (-x + _thickness(x) *
          sin(theta(x, .1, chord(z) / 2))),
        r = max(
          .1, 
          ((camber(x, .1, chord(z) / 2) + _thickness(x)) *
            chord(z) * cos(theta(x, .1, chord(z) / 2))) +
            roll + _curvature * pow(z * roll, 2)
        )
      ) [
        (sin(min(max(a * 180 / PI / r, -179), 179))) * r,
        (cos(min(max(a * 180 / PI / r, -179), 179))) * r -
          roll,
        z
      ]]
    )
  ], j = i) j]
);

faces = concat(
  [for(i = [for(x = [0:xseg * 2], xmax = xseg * 4 + 1)
    quad(
      x,
      x + 1,
      xmax - x - 1,
      xmax - x,
      true
    )], v = i) v],
  [for(i = [for(
    z = [0:zseg - 1],
    x = [0:xseg * 4 + 1],
    xmax = xseg * 4 + 2
  )
    quad(
      z * xmax + x,
      z * xmax + x + xmax,
      z * xmax + x + (((x % xmax) == xmax - 1) ? 0 : xmax) + 1,
      z * xmax + x - (((x % xmax) == xmax - 1) ? xmax : 0) + 1,
      true
    )], v = i) v],
  [for(i = [for(x = [0:xseg * 2], xmax = xseg * 4 + 1)
    quad(
      len(points()) - 1 - (x),
      len(points()) - 1 - (x + 1),
      len(points()) - 1 - (xmax - x - 1),
      len(points()) - 1 - (xmax - x),
      true
    )], v = i) v]
);

echo(presets[preset]);

for(petal = [_petalOffset:_petalOffset + _petals - 1])
  rotate([0, 0, petal * goldenAngle])
    translate([0, petal * _petalSpacing, 0])
      rotate([-petal * _openness, 0, 0])
        scale([
          _width,
          _width,
          _length * 
            (1 - pow(
              petal * _openness * _curvature * _shorten / 100,
              3
            ))
        ]) polyhedron(
          points(petal * _petalSpacing / _width),
          faces
        );

translate([0, 0, -_width / 2]) 
  scale(max(
    minbase,
    ((_petalOffset + _petals) * _petalSpacing + _width)
  ) / 50)
    intersection() {
      scale([1, 1, .5]) sphere(50);
      translate([0, 0, 50]) cube(100, center = true);
    }