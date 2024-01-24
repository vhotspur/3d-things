
corner_length = 35;
corner_height = 54;
door_thickness = 9;
overlap_thickness = 2;
overlap_length = 30;
overlap_height = 30;
overlap_cut = 10;
hinge_diameter = 5.5;
hinge_distance = 7;
hinge_depth = corner_height / 2;
brim_height = 0.2;
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
    translate([0, (2*overlap_thickness + door_thickness)/2, 0]) rotate([90, 0, 0]) {
        translate([0, 0, overlap_thickness + door_thickness]) {
            linear_extrude(overlap_thickness) {
                make_cut_triangle(
                    corner_length + overlap_length,
                    corner_height + overlap_height,
                    overlap_cut
                );
            }
        }
        translate([0, 0, overlap_thickness]) {
            linear_extrude(door_thickness) {
                make_triangle(corner_length, corner_height);
            }
        }
        linear_extrude(overlap_thickness) {
            make_cut_triangle(
                corner_length + overlap_length,
                corner_height + overlap_height,
                overlap_cut
            );
        }
    }
    translate([hinge_distance, 0, -1]) {
        cylinder(hinge_depth+1, d=hinge_diameter);
    }
}

if (brim_height > 0) {
    translate([corner_length + brim_offset, - (door_thickness / 2) + brim_offset, 0]) {
        cube([overlap_length - brim_offset - overlap_cut, door_thickness - 2*brim_offset, brim_height]);
    }
}
