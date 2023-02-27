//===============================================================================
// Imports
include <round-anything.scad>

//===============================================================================
// Modules

//-------------------------------------------------------------------------------
// Used to print information about measurements
//
// INPUT:
// * dim_name : Name of the property to be displayed
// * points   : List of points to be displayed
//
// OUTPUT:
// * NONE
//
module print_dims(dim_name, points)
{
  echo("===============================================================");

  echo("INFO FOR: ", dim_name);

  for (p = points, i = 0)
  {
    echo(p);
  }

  echo("===============================================================");
}

//-------------------------------------------------------------------------------
// Creates the outermost cutout of the mug
//
// INPUT:
// * p_size     : Plate size
// * thickness  : Thicknesses of the upper, lower, and mug-adjacent sides
// * c_rad      : Curve radius of handle
// * fn         : Quality of circles
//
// OUTPUT:
// * Rough mug cutout
//
module rough_cutout(p_size, thickness, c_rad, fn)
{
  // Create the rounded corner version of cutout
  outer_points  =
  [
    [0.0       , 0.0      , c_rad*3.3],
    [0.0       , p_size[1],     0],
    [p_size[0] , p_size[1], c_rad],
    [p_size[0] , 0.0      , c_rad]
  ];

  polyRoundExtrude(outer_points, p_size[2], 4, 4, 10);
}

//-------------------------------------------------------------------------------
// Rough cutout of the handle grip
//
// INPUT:
// * p_size     :
// * thickness  :
// * inner_dims : Dimensions of handle cutout
// * c_rad      :
// * fn         :
//
// OUTPUT:
// * Handle cutout
//
module rough_handle(p_size, inner_dims, thickness, c_rad, fn)
{
  // Inner points (bottom left -> top left -> top right -> bottom right):w
  ix1 = thickness[0]                 ; iy1 = thickness[2]             ;
  ix2 = ix1                          ; iy2 = p_size[1] - thickness[1] ;
  ix3 = thickness[0] + inner_dims[0] ; iy3 = iy2                      ;
  ix4 = thickness[0] + inner_dims[1] ; iy4 = iy1                      ;

  // Handle points for polygon
  inner_points  =
  [
    [ix1, iy1, c_rad*4.2],
    [ix1, iy2, c_rad*1.5],
    [ix3, iy2, c_rad/1.5],
    [ix4, iy1, c_rad/1.5]
  ];

  translate([0,0,-c_rad/2])
    polyRoundExtrude(inner_points, p_size[2]+thickness[1], -10, -10, $fn=fn);
}

//-------------------------------------------------------------------------------
// Cutout the contour of the handle against the mug
//
// INPUT:
// * d : Diameter of mug
// * p : Plates sizes
// * t : Thicknesses of mug
// * fn: Quality of circles
//
// OUTPUT:
// * Mug contour cutout
//
module mug_contour(d, p, t, fn)
{
  // Translate the cylinder to the appropriate position, then rotate it 90
  // degrees, then draw the cylinder. Draw the cutout red to make it easy
  // to see.
  color([1,0,0])
  translate([(t[0]-d)/2,-p[2]/5,p[2]/2])
  rotate([-90,0,0])
    cylinder(h = p[1]+5, d = d, $fa=5, $fn=fn);
}

//-------------------------------------------------------------------------------
// Cutout the handle mug mounts
//
// INPUT:
// * p : Plates sizes
// * it : Inner cutout thicknesses
//
// OUTPUT:
// * Mount cutout
//
module mount_cutout(p, it)
{
  // Thickness at top and bottom
  t      = 2;

  // Mount cutout size
  ct_x   = 11;
  ct_y   = 6.2;
  ct_z   = 8.1;

  cb_x   = 11;
  cb_y   = 4;
  cb_z   = 7.1;

  // Center of mounts
  xt_c   = 0;
  yt_c   = p[1]-ct_y-t;
  zt_c   = (p[2]-ct_z)/2;

  xb_c   = xt_c;
  yb_c   = t + (p[1]-80);
  zb_c   = (p[2]-cb_z)/2;

  // Screw position
  x_spos = 7.2;
  y_spos = p[1]-it[1];
  z_spos = p[2]/2;

  // Bottom
  color([1, 0, 0.5])
    translate([xb_c, yb_c, zb_c])
    cube([cb_x, cb_y, cb_z]);

  // Top
  color([1, 0.5, 0])
    translate([xt_c, yt_c, zt_c])
    cube([ct_x, ct_y, ct_z]);

  // Screw
  color([0.5, 0.75, 0])
  {
    translate([x_spos, y_spos-1, z_spos])
      rotate([90, 0, 0])
      cylinder(d=6, h=10, $fn=100);

    translate([x_spos, y_spos, z_spos])
      rotate([90, 0, 0])
      cylinder(d=3, h=3, $fn=100);
  }
}

//===============================================================================
// Script

// Preview quality
fn = 100;

// Cutout variables [cm]
handle_curve_rad = 8;
plate_size       = [50, 95, 22];                                                 // (x,y,z) dimensions of the rectangle to cut
                                   // out the handle
inner_handle_dim = [40, 40];                                                     // Top and bottom inner mug handle lengths
handle_thickness = [4, 8, 5];                                                   // Left, top, and bottom thicknesses
mug_diameter     = 87;                                                           // Diameter of mug

//rough_handle(plate_size, inner_handle_dim, handle_thickness, handle_curve_rad, fn);

// Create handle
difference()
{
  // Rough cutout of handle
  rough_cutout(plate_size, handle_thickness, handle_curve_rad, fn);

  // Rough cutout of inner handle
  rough_handle(plate_size, inner_handle_dim, handle_thickness, handle_curve_rad, fn);

  // Cut away contour with mug
  mug_contour(mug_diameter, plate_size, handle_thickness, fn);

  // Cut away mount holes
  mount_cutout(plate_size, handle_thickness);
}
