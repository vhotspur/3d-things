
board_width = 89;
board_dip_size = 2;

rig_height = 30;
rig_skid_width = 3;
rig_overlap = 30;

hole_diameter = 3;
hole_from_edge = [15, 15, 15, 15, 15];
hole_offset = 10;
first_hole_offset = 10;

scale_diameter = 2;

$fn = 100;

total_width = (len(hole_from_edge) - 1) * hole_offset + 2 * first_hole_offset;

module skid() {
    rotate([90, 0, 90]) {
        linear_extrude(total_width) {
            polygon([
                [-rig_skid_width/2, 0],
                [rig_skid_width/2, 0],
                [0,board_dip_size]
            ]);
        }
    }
}

difference() {
    union() {
        translate([0, -rig_overlap, 0]) {
            cube([total_width, board_width + 2 * rig_overlap, rig_height]);
        }
        translate([0, 0, rig_height]) skid();
        translate([0, board_width, rig_height]) skid();
    }

    for (i=[0:(len(hole_from_edge)-1)]) {
        let (
            shift_x = i * hole_offset + first_hole_offset,
            shift_y_1 = hole_from_edge[i],
            shift_y_2 = board_width - shift_y_1,
            markers = [
                [shift_x, -rig_overlap],
                [shift_x, board_width + rig_overlap],
                [0, shift_y_1],
                [total_width, shift_y_1],
                [0, shift_y_2],
                [total_width, shift_y_2]
            ]
        ) {
            translate([shift_x, shift_y_1, rig_height / 2]) {
                cylinder(h=2*rig_height, d=hole_diameter, center=true);
            }
            translate([shift_x, shift_y_2, rig_height / 2]) {
                cylinder(h=2*rig_height, d=hole_diameter, center=true);
            }
            
            for (marker=markers) {
                translate([marker[0], marker[1], 0]) {
                    cylinder(h=4*rig_height, d=scale_diameter, center=true);
                }
            }
        }
    }
}
