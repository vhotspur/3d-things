
// http://l-gauge.org/wiki/index.php?title=Track_Geometry

to_print = 300;

base_height = 3.2;
base_width = 7.8;
rail_height = 6;
rail_width = 2.5;
gauge = 37.5;
connection_diameter = 5;
connection_diameter_scaling = 0.05;
connection_size = 2.5;
connection_width = 3;
connection_width_scaling = 0.05;
connection_uncenter = 12;
connection_expected_gap = 0.2;


$fn = 100;

echo(str("Actual gauge is ", gauge));

module make_rail_section() {
    shift = (base_width - rail_width)/2;
    translate([-base_width/2, 0]) polygon([
        [0, 0],
        [base_width, 0],
        [base_width, base_height],
        [base_width - shift, base_height],
        [base_width - shift, base_height + rail_height],
        [shift, base_height + rail_height],
        [shift, base_height],
        [0, base_height]
    ]);
}

function universal_scale(value, scale_factor, scale_direction=0) =
    scale_direction == 0 ? value : (
        scale_direction > 0 ? value * (1 + scale_factor) : value * (1 - scale_factor)
    );

module make_connection_peg_2d(rescaled=0, extra_shoulder=0) {
    circle_diameter = universal_scale(
        connection_diameter,
        connection_diameter_scaling,
        rescaled
    );
    shoulder_width = universal_scale(
        connection_width,
        connection_width_scaling,
        rescaled
    );
    shoulder_length = connection_size + (
        rescaled == 0 ? 0 :
        (
            rescaled > 0 ? -connection_expected_gap/2 : +connection_expected_gap/2
        )
    );

    translate([shoulder_length, 0, 0]) {
        circle(d=circle_diameter);
    }
    translate([shoulder_length/2, 0]) {
        square([shoulder_length+extra_shoulder, shoulder_width], center=true);
    }

}

module make_connecting_crosstie() {
    difference() {
        translate([0, 0, base_height/2]) {
            cube([base_width, gauge, base_height], center=true);
        }
        translate([base_width/2, connection_uncenter, -base_height/2]) {
            rotate([0, 0, 180]) {
                linear_extrude(base_height*2) {
                    make_connection_peg_2d(1, 1);
                }
            }
        }
    }
    translate([base_width/2, -connection_uncenter]) {
        linear_extrude(base_height) {
            make_connection_peg_2d(-1, 1);
        }
    }
}

module make_straight_track(size) {
    rotate([90, 0, 90]) {
        linear_extrude(size * base_width) {
            translate([-gauge/2 - rail_width/2, 0]) make_rail_section();
            translate([+gauge/2 + rail_width/2, 0]) make_rail_section();
        }
    }
    rotate([0, 0, 180]) translate([-base_width/2, 0, 0]) {
        make_connecting_crosstie();
    }
    if (size > 5) {
        for (i=[1:size/4-1]) {
            translate([(4*i - 1)*base_width, -gauge/2, 0]) {
                cube([base_width*2, gauge, base_height]);
            }
        }
    }
    translate([-base_width/2 + (size)*base_width, 0, 0]) {
        make_connecting_crosstie();
    }
}

module make_curve_track(circle_fragment=16, crosstie_count=3) {
    curve_angle = 360/circle_fragment;
    the_radius = 38*base_width;
    crosstie_offset = the_radius + gauge/2 + rail_width/2;
    rotate_extrude(convexity=4, angle=curve_angle) {
        translate([the_radius, 0]) make_rail_section();
        translate([the_radius+gauge+rail_width, 0]) make_rail_section();
    }
    translate([crosstie_offset, base_width/2, 0]) {
        rotate([0, 0, 270]) {
            make_connecting_crosstie();
        }
    }
    rotate([0, 0, curve_angle]) {
        translate([crosstie_offset, -base_width/2, 0]) {
            rotate([0, 0, 90]) {
                make_connecting_crosstie();
            }
        }
    }

    for (i=[1:crosstie_count-1]) {
        rotate([0, 0, i*curve_angle/crosstie_count]) {
            translate([crosstie_offset - gauge/2, -base_width, 0]) {
                cube([gauge, base_width*2, base_height]);
            }
        }
    }
}

module make_connection_test(monorail=false) {
    difference() {
        translate([0, 0, base_height/2]) {
            cube([base_width, base_width*4, base_height], center=true);
        }
        translate([base_width/2, base_width, -base_height/2]) {
            rotate([0, 0, 180]) {
                linear_extrude(base_height*2) {
                    make_connection_peg_2d(1, 1);
                }
            }
        }
    }
    translate([base_width/2, -base_width]) {
        linear_extrude(base_height) {
            make_connection_peg_2d(-1, 1);
        }
    }
    if (monorail) {
        translate([-base_width/2, 0, 0]) {
            rotate([90, 0, 90]) {
                linear_extrude(base_width) {
                    make_rail_section();
                }
            }
        }
    }
}

if ((to_print == 0) || (to_print == 1)) {
    make_connection_test(to_print == 1);
}

if ((to_print == 2) || (to_print == 3)) {
    make_connection_test(to_print == 3);
    translate([base_width+connection_expected_gap, 0, 0]) {
        rotate([0, 0, 180]) {
            make_connection_test(to_print == 3);
        }
    }
}

if (to_print == 10) {
    make_connecting_crosstie();
}

if ((to_print > 100) && (to_print < 200)) {
    make_straight_track(to_print - 100);
}

if (to_print == 200) {
    make_curve_track(16, 3);
}
if (to_print == 204) {
    make_curve_track(12, 4);
}

if (to_print == 300) {
    translate([-38*base_width, 0, 0]) {
        make_curve_track(16, 3);
    }
    translate([gauge + 3*base_width + rail_width - 1, 15*base_width - 4, 0]) {
        rotate([0, 0, 180-360/16]) {
            translate([-38*base_width, 0, 0]) {
                make_curve_track(16, 3);
            }
        }
    }
}
