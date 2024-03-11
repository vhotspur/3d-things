

backstop_thickness = 15;
backstop_height = 34;
rig_width = 90;
rig_length = 50;
rig_thickness = 15;
hole_diameter = 16.2;
hole_distance = 9;
dowel_diameter = 8;
dowel_gap_bottom = 2;
dowel_depth_left = 20;

$fn = 100;

backstop_total_height = backstop_height + rig_thickness;

difference() {
    translate([0, -rig_width / 2, 0]) {
        cube([backstop_thickness, rig_width, backstop_total_height]);
    }
    rotate([0, 90, 0]) {
        shift_x = - dowel_gap_bottom - dowel_diameter/2;
        translate([shift_x, 0, -1]) {
            cylinder(2+backstop_thickness, d=dowel_diameter);
        }
        translate([shift_x - backstop_total_height, -dowel_diameter/2, -1]) {
            cube([backstop_total_height, dowel_diameter, 2+backstop_thickness]);
        }
    }
}
difference() {
    translate([-rig_length, -rig_width/2, 0]) {
        cube([rig_length, rig_width, rig_thickness]);
    }
    translate([-hole_distance, 0, -1]) {
        cylinder(h=2+rig_thickness, d=hole_diameter);
    }
    
    translate([-rig_length + dowel_depth_left, 0, -1]) {
        cylinder(2+rig_thickness, d=dowel_diameter);
    }
    translate([-rig_length - 1, -dowel_diameter/2, -1]) {
        cube([dowel_depth_left, dowel_diameter, 2+rig_thickness]);
    }
}
