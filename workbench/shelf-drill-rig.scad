
$fn = 100;

rig_width = 50;
rig_height = 15;
rig_skid_width = 8;
rig_skid_height = 15;

rod_diameter = 6.5;

hole_count = 5;
hole_margin = 35;
hole_diameter = 13;
hole_distance = 32;

dovetail_half_count = 2;
dovetail_offset = 3;
dovetail_depth = 5;

/*
rig_width = 25;
rig_height = 5;
rig_skid_width = 4;
rig_skid_height = 4;
rod_diameter = 2;
hole_count = 3;
hole_diameter = 4;
hole_margin = 10;
hole_distance = 16;
dovetail_half_count = 2;
dovetail_offset = 2;
dovetail_depth = 4;
//*/


function flatten_list(data) = [
    for (i = data) 
        for (j = i) j
];
        
function make_dovetail_joint(
        half_count,
        total_length,
        depth,
        backoffset) =
    let(
        count = 2 * half_count,
        size = (total_length + (count - 1) * backoffset) / count
    )
    flatten_list([
        for (i=[1:half_count]) let(
            start_y = 2*(i-1)*(size - backoffset)
        ) [
            [0, start_y],
            [0, start_y + size],
            [depth, start_y + size - backoffset],
            [depth, start_y + size - backoffset + size]
        ]
    ]);

hole_left_distance = dovetail_depth/2 + hole_distance/2;
hole_right_distance = hole_left_distance + (hole_count - 1)* hole_distance + dovetail_depth/2 + hole_distance/2;
rig_length = hole_count * hole_distance + dovetail_depth;

left_side_coords = make_dovetail_joint(dovetail_half_count, rig_width, dovetail_depth, dovetail_offset);
right_side_coords = [
    for (i=left_side_coords)
        [rig_length - i[0], rig_width - i[1]]
];
base_polygon = concat(left_side_coords, right_side_coords);

difference() {
    union() {
        linear_extrude(rig_height) {
            polygon(base_polygon);
        }
        translate([0, -rig_skid_width, 0]) {
            cube([rig_length - dovetail_depth, rig_skid_width, rig_skid_height + rig_height]);
        }
    }
    for (i=[hole_left_distance:hole_distance:hole_right_distance]) {
        translate([i, hole_margin, -1]) {
            cylinder(h=rig_height + 2, d=hole_diameter);
        }
    }
    rotate([90, 0, 0]) {
        for (i=[hole_left_distance + hole_distance/2:hole_distance:hole_right_distance - hole_distance/2]) {
            translate([i, rig_height/2, -rig_width-1]) {
                cylinder(h=rig_width + rig_skid_width + 2, d=rod_diameter);
            }
        }
    }
}
