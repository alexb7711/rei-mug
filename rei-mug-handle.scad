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
// * inner_dims : Dimensions of handle cutout
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
  translate([0, 0, 0])
  cube([thickness[0], p_size[1], p_size[2]]);
}

//-------------------------------------------------------------------------------
// Rough cutout of the handle grip
//
// INPUT:
// *
//
// OUTPUT:
// *
//
module rough_handle(p_size, thickness, c_rad, fn)
{
  // Scalar value
  scale     = 1.1;
  p_size    = [p_size[0]/scale, p_size[1]/scale, 2*p_size[2]];
  thickness = thickness / scale;

  // Create the rounded corner version of cutout
  translate([(p_size[0] + c_rad)/7.5, (p_size[1] + c_rad)/10, -thickness[0]])
  minkowski()
  {
    cube([p_size[0]-c_rad, p_size[1]-c_rad, p_size[2]/2]);
    cylinder(r=c_rad/2, h=p_size[2]/2, $fn=fn);
  }
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
  translate([(t[0]-d)/2.0,-p[2]/5.0,p[2]/2.0])
  rotate([-90,0,0])
    cylinder(h = p[1]+1, d = d, $fa=5, $fn=fn);
}

//===============================================================================
// Script

// Preview quality
fn = 30;

// Cutout variables [cm]
handle_curve_rad = 1;
plate_size       = [5, 8.0, 2.2]; // (x,y,z) dimensions of the rectangle to cut out the handle
inner_handle_dim = [3.0, 4.0];      // Top and bottom inner mug handle lengths
handle_thickness = [0.4, 1.0, 1.0]; // Left, top, and bottom thicknesses
mug_diameter     = 8.7;             // Diameter of mug

// Create handle
difference()
{
  // Rough cutout of handle
  rough_cutout(plate_size, handle_thickness, handle_curve_rad, fn);

  // Rough cutout of inner handle
  color([0,0,1])
  rough_handle(plate_size, handle_thickness, handle_curve_rad, fn);

  // Cut away contour with mug
  mug_contour(mug_diameter, plate_size, handle_thickness, fn);
}
