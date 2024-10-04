

size_divisor = 3;
long_barrier_count = 0;
short_barrier_count = 1;

max_height = 66;

width = 78;
depth = 98;
thickness = 1.4;
height = max_height / size_divisor;
divider_height = 0.6 * height;

holder_inner_diameter = 8;
holder_outer_diameter = 8 + 2*4;
holder_pin_width = 10;
holder_top_space = 1;

holder_pin_height = height - holder_top_space - holder_outer_diameter / 2;
echo(holder_pin_height);

$fn = 100;

translate([-width/2, -depth/2, 0]) {
    difference() {
        cube([width, depth, height]);
        translate([thickness, thickness, thickness]) {
            cube([width - 2*thickness, depth-2*thickness, height]);
        }
    }
}

difference() {
    union() {
        if (long_barrier_count > 1) {
            for (i=[1:long_barrier_count]) let(
                x = i*(width-2*thickness)/(long_barrier_count+1) + thickness/2
            ) {
                translate([-width/2 + x, -depth/2, thickness]) {
                    cube([thickness, depth, divider_height]);
                }
            }
        }

        if (short_barrier_count > 0) {
            for (i=[1:short_barrier_count]) let(
                y = i*(depth-2*thickness)/(short_barrier_count+1) + thickness/2
            ) {
                translate([-width/2, -depth/2 + y, thickness]) {
                    cube([width, thickness, divider_height]);
                }
            }
        }

        translate([0, thickness/2, 0]) {
            rotate([90, 0, 0]) {
                linear_extrude(thickness) {
                    translate([-holder_pin_width/2, 0]) {
                        square([holder_pin_width, holder_pin_height]);
                    }
                    translate([0, holder_pin_height]) {
                        circle(d=holder_outer_diameter);
                    }
                }
            }
        }
    }
    translate([0, thickness/2+1, 0]) {
        rotate([90, 0, 0]) {
            linear_extrude(thickness+2) {
                translate([0, holder_pin_height]) {
                    circle(d=holder_inner_diameter);
                }
            }
        }
    }
}
