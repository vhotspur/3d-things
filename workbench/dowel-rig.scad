

board_width = 18.5;
rig_wall_height = 40;
rig_wall_thickness = 8;
rig_width = 218;
rig_bottom_thickness = 20;
hole_diameter = 16.3;
hole_count = 5;
hole_center_distance = 45;

corner_radius = rig_wall_thickness / 3;

$fn = 100;

marker_depth_small = corner_radius + 1;
marker_depth_large = marker_depth_small * 1.5; // rig_wall_height
marker_width = 1;
marker_center_distance_small = 5;
marker_large_multiple = 2;

first_hole_shift = hole_center_distance * (hole_count - 1) / 2;
marker_half_count = floor(rig_width / marker_center_distance_small / 2) + 3;


module cube_with_one_rounded_edge(width, depth, height, radius) {
    translate([radius, 0, 0]) {
        cube([width-radius, depth, height]);
    }
    translate([0, radius, 0]) {
        cube([width, depth-radius, height]);
    }
    translate([radius, radius, 0]) {
        cylinder(h=height, r=radius, center=false);
    }
}

difference() {
    translate([-board_width/2 - rig_wall_thickness,  -rig_width/2, 0]) {
       cube([
            board_width + 2*rig_wall_thickness,
            rig_width,
            rig_bottom_thickness
        ]);
    }
    for (i=[1:hole_count]) {
        translate([0, (i-1)*hole_center_distance - first_hole_shift, rig_bottom_thickness/2-1]) {
            cylinder(h=rig_bottom_thickness+3, d=hole_diameter, center=true);
        }
    }
}

// Just to keep the amount of duplicate code minimal
wall_parameters = [
    [board_width/2, rig_width/2, 0],
    [-board_width/2, -rig_width/2, 180],
];

difference() {
    for (i=wall_parameters) {
        translate([i[0], i[1], rig_wall_height + rig_bottom_thickness]) {
            rotate([90, 90, i[2]]) {
                cube_with_one_rounded_edge(
                    rig_wall_height,
                    rig_wall_thickness,
                    rig_width,
                    corner_radius
                );
            }
        }
    }

    for (i=[-marker_half_count:1:marker_half_count]) {
        is_big = i % marker_large_multiple == 0;
        marker_size = is_big ? marker_depth_large : marker_depth_small;
        translate([
                -board_width/2 - rig_wall_thickness - 1,
                -marker_width/2 + i*marker_center_distance_small,
                rig_bottom_thickness + rig_wall_height - marker_size
        ]) {
            cube([
                board_width + 2*rig_wall_thickness + 2,
                marker_width,
                marker_size + 1
            ]);
        }
    }
}

