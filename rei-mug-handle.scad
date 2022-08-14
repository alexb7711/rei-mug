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
  translate([c_rad/2, c_rad/2, 0])
  minkowski()
  {
    cube([p_size[0]-c_rad, p_size[1]-c_rad, p_size[2]/2]);
    cylinder(r=c_rad/2, h=p_size[2]/2, $fn=fn);
  }

  // Add in the squared off edges for the mug connection
  cube([thickness[0], p_size[1], p_size[2]]);
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
  ix2 = ix1                          ; iy2 = p_size[1] - thickness[2] ;
  ix3 = thickness[0] + inner_dims[0] ; iy3 = iy2                      ;
  ix4 = thickness[0] + inner_dims[1] ; iy4 = iy1                      ;

  // Handle points for polygon
  inner_points  =
  [
    [ix1, iy1, c_rad/2],
    [ix1, iy2, c_rad],
    [ix3, iy2, c_rad],
    [ix4, iy1, c_rad]
  ];

  translate([0,0,-5])
  polyRoundExtrude(inner_points, p_size[2]+thickness[1], -12, -12, $fn=fn);
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
  // Mount cutout size
  c_x   = 10;
  c_y   = 6;
  c_z   = 9;

  // Center of mounts
  x_c   = 0;
  y_c   = p[1]-2;
  z_c   = (p[2]-c_z)/2;

  // Screw position
  x_spos = p[0]/2;
  y_spos = p[1]-2-c_y;
  z_spos = p[2]/2-c_z/2;

  // Bottom
  color([1, 0, 0.5])
    translate([x_c, c_y+2, z_c])
    mirror([0,1,0])
    cube([c_x, c_y, c_z]);

  // Top
  color([1, 0.5, 0])
    translate([x_c, y_c, z_c])
    mirror([0,1,0])
    cube([c_x, c_y, c_z]);

  // Screw
  color([1, 0.5,0])
  {
    translate([7.5, p[1]-it[1]+1, p[2]/2])
      rotate([90, 0, 0])
      cylinder(d=5, h=5, $fn=100);

    translate([7.5, p[1]-it[1]+2, p[2]/2])
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
plate_size       = [50, 80, 22];   // (x,y,z) dimensions of the rectangle to cut out the handle
inner_handle_dim = [40, 40];      // Top and bottom inner mug handle lengths
handle_thickness = [4, 10, 10]; // Left, top, and bottom thicknesses
mug_diameter     = 87;             // Diameter of mug

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
