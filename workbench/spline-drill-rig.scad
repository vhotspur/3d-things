
board_width = 93;
board_height = 10;

//rig_height = 10;
rig_height = 30;
rig_size = 120;
rig_skid_width = 10;

hole_diameter = 3;
hole_from_edge = [15, 15, 15, 15, 15, 15, 15, 15];
hole_offset = 10;
first_hole_offset = 10;

scale_diameter = 2;

$fn = 50;

total_width = (len(hole_from_edge) - 1) * hole_offset + 2 * first_hole_offset;

difference() {
    translate([0, -rig_skid_width, 0]) {
        cube([total_width, rig_size + rig_skid_width, rig_height]);
        cube([total_width, rig_skid_width, rig_height + board_height]);
    }

    for (i=[0:(len(hole_from_edge)-1)]) {
        let (
            shift_x = i * hole_offset + first_hole_offset,
            shift_y_1 = hole_from_edge[i],
            shift_y_2 = board_width - shift_y_1,
            markers = [
                [shift_x, rig_size],
                [shift_x, -rig_skid_width],
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
                    cylinder(h=4*(board_height + rig_height), d=scale_diameter, center=true);
                }
            }
        }
    }
}


