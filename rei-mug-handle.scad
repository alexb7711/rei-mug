//===============================================================================
// Functions
function print_dims(dim_name, points)
{
	echo("===============================================================");
	
	echo("INFO FOR: ", dim_name);

	for (p = points, i = [1 : len(points)])
	{
		echo()
	}

	echo("===============================================================");
}

//===============================================================================
// Modules

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

	echo("ROUGH CUTOUT MATH");
	echo("1: (", ix1,iy1,")");
	echo("2: (", ix2,iy2,")");
	echo("3: (", ix3,iy3,")");
	echo("4: (", ix4,iy4,")");

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
}

//===============================================================================
// Script

// Cutout variables [cm]
plate_size       = [5.0, 8.0, 2.2]; // (x,y,z) dimensions of the rectangle to cut out the handle
inner_handle_dim = [3.0, 4.0];      // Top and bottom inner mug handle lengths
handle_thickness = [0.4, 1.0, 1.0]; // Left, top, and bottom thicknesses

// Outline the mug
rough_cutout(plate_size, inner_handle_dim, handle_thickness);
