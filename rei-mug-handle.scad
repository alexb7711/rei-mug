
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
// * p_size: Plate size
// * inner_dims : Dimensions of handle cutout
// * thickness: Thicknesses of the upper, lower, and mug-adjacent sides
//
// OUTPUT:
// * Rough mug cutout
//
module rough_cutout(p_size, inner_dims, thickness)
{
  // Inner points (bottom left -> top left -> top right -> bottom right):w
  ix1 = thickness[0]                 ; iy1 = thickness[2]             ;
  ix2 = ix1                          ; iy2 = p_size[1] - thickness[2] ;
  ix3 = thickness[0] + inner_dims[0] ; iy3 = iy2                      ;
  ix4 = thickness[0] + inner_dims[1] ; iy4 = iy1                      ;

  // Handle points for polygon
  inner_points  =
    [
      [ix1, iy1],
      [ix1, iy2],
      [ix3, iy2],
      [4.4, 1.0]
      ];

  outer_points  =
    [
      [0.0, 0.0],
      [0.0, p_size[1]],
      [p_size[0], p_size[1]],
      [p_size[0], 0.0]
      ];

   handle_points = concat(inner_points, outer_points);

  // Handle paths for polygon
  inner_paths  = [[0,1,2,3]];
  outer_paths  = [[4,5,6,7]];
  handle_paths = concat(inner_paths, outer_paths);

  // Create mug rough sketch
  linear_extrude(height=p_size[2], center=false)
    polygon(points=handle_points, paths=handle_paths);

  // Debug info
   print_dims("inner_points", inner_points);
   print_dims("outer_points", outer_points);
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
plate_size       = [5, 8.0, 2.2]; // (x,y,z) dimensions of the rectangle to cut out the handle
inner_handle_dim = [3.0, 4.0];      // Top and bottom inner mug handle lengths
handle_thickness = [0.4, 1.0, 1.0]; // Left, top, and bottom thicknesses
mug_diameter     = 8.7;             // Diameter of mug

/* color([0,1,0]) */
/* translate([handle_thickness[0] + inner_handle_dim[0],plate_size[1]-handle_thickness[1],-plate_size[2]/7]) */
/* cylinder(h=plate_size[2]+1, d=1, $fn=fn); */

// Create handle
difference()
{
  // Rough cutout of handle
  rough_cutout(plate_size, inner_handle_dim, handle_thickness);

  // Cut away contour with mug
  mug_contour(mug_diameter, plate_size, handle_thickness, fn);
}
