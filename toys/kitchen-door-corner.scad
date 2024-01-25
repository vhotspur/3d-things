
// Bottom length of the cut corner
corner_length = 32;
// Height of the cut corner
corner_height = 30;
// Original material thickness
door_thickness = 9;

//
// You probably do not need to change the rest of the values
//
overlap_thickness = 2;
overlap_length = 30;
overlap_height = 30;
overlap_cut = 10;
hinge_diameter = 5.5;
hinge_distance = 6.5;
hinge_depth = corner_height / 2;
brim_height = 0;
brim_offset = 0.1;

$fn = 100;

module make_triangle(a, b) {
    polygon([[0, 0], [a, 0], [0, b]]);
}

module make_cut_triangle(a, b, cut_size) {
    polygon([
        [0, 0],
        [a - cut_size, 0],
        [a - cut_size, cut_size * b / a],
        [cut_size, b - cut_size * b / a],
        [0, b - cut_size * b / a]
    ]);
}

difference() {
    // Shift to center and rotate to vertical position.
    translate([
            overlap_thickness,
            (2*overlap_thickness + door_thickness)/2,
            overlap_thickness
    ]) rotate([90, 0, 0]) {
        // Rounded corners with cut middle.
        difference() {
            minkowski() {
                translate([0, 0, overlap_thickness]) linear_extrude(door_thickness) {
                    make_cut_triangle(
                        corner_length + overlap_length,
                        corner_height + overlap_height,
                        overlap_cut
                    );
                }
                sphere(r=overlap_thickness);
            }
            translate([-2*overlap_thickness, -2*overlap_thickness, overlap_thickness]) {
                cube([
                    corner_length + overlap_length + 4*overlap_thickness,
                    corner_height + overlap_height + 4*overlap_thickness,
                    door_thickness
                ]);
            }
        }

        // Middle part - the actual missing corner
        // The complexity comes from the fact that we need to add one rounded
        // corner only.
        translate([-overlap_thickness, -overlap_thickness, overlap_thickness]) {
            difference() {
                linear_extrude(door_thickness) {
                    make_triangle(corner_length, corner_height);
                }
                translate([0, 0, -1]) difference() {
                    translate([-overlap_thickness, -overlap_thickness, -1]) {
                        cube([2*overlap_thickness, 2*overlap_thickness, door_thickness+3]);
                    }
                    translate([overlap_thickness, overlap_thickness, -2]) {
                        cylinder(h=door_thickness+4, r=overlap_thickness);
                    }
                }
            }
        }
    }

    // Hinge hole
    translate([hinge_distance, 0, -1]) {
        cylinder(hinge_depth+1, d=hinge_diameter);
    }

}

// Forced brim.
if (brim_height > 0) {
    translate([corner_length + brim_offset, - (door_thickness / 2) + brim_offset, 0]) {
        cube([overlap_length - brim_offset - overlap_cut, door_thickness - 2*brim_offset, brim_height]);
    }
}
