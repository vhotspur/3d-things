
width = 60;
height = 90;

text_shift = 2;
text_size = 5;
text_angle = 16.5;

leaf_height = 55;
leaf_shift_y = 8;
leaf_shift_x = -2;

left_acorn_shift_y = -20;
left_acorn_shift_x = -6;
right_acorn_shift_y = -20;
right_acorn_shift_x = -6;

screw_offset_x = width * 0.41;
screw_offset_y = - 3;
screw_diameter = 2.5;

thickness_base = 2;
thickness_leaf = 1;
thickness_acorn = 0.5;

$fn = 100;


module onto_circle(radius, start_angle, end_angle, reverse_children=false) {
    spacing = (end_angle - start_angle) / ($children - 1);
    rotate([0, 90, 0]) {
        for (a = [0:$children-1]) {
            rotate([0, start_angle + (a * spacing), 270])
            translate([radius,0,0])
            rotate([0,270,90])
            if (reverse_children) {
                children($children - a - 1);
            } else {
                children(a);
            }
        }
    }
}

module letter(the_letter) {
    rotate([0, 0, 180]) {
        linear_extrude(thickness_leaf) {
            text(the_letter, size=text_size, halign="center", valign="top");
        }
    }
}

module make_acorn(height, filename, number, frac=0.01) {
    translate([0, 0, - height * frac]) {
        // Get rid of bottom layer from the white color
        intersection() {
            translate([0, 0, height * (1 - frac)]) {
                resize([0, 0, height], auto=true) {
                    surface(filename, invert=true, number);
                }
            }
            cube([20, 20, 20]);
        }
    }
}


color("yellow") {
    difference() {
        translate([0, 0, -thickness_base]) linear_extrude(thickness_base) {
            polygon([
                [-width/2, 0],
                [width/2, 0],
                [0, -height]
            ]);
        }
        union() {
            for (a = [-1, 1]) {
                translate([a * screw_offset_x, screw_offset_y, -thickness_base - 1]) {
                    cylinder(thickness_base + 2, d = screw_diameter);
                }
            }
            if (false) { translate([0, 0, -thickness_base / 2]) linear_extrude(thickness_base) {
                translate([0, -height * 0.74, 0]) {
                    text("2024", size=text_size * 0.7, halign="center", valign="top");
                }
                translate([0, -height * 0.79, 0]) {
                    text("17/8", size=text_size * 0.7, halign="center", valign="top");
                }
            }}
            
            rotate([0, 180, 0]) translate([0, 0, thickness_base * 0.8]) linear_extrude(thickness_base) {
                translate([0, -height * 0.1, 0]) {
                    text("17.8.", size=text_size * 1.5, halign="center", valign="top");
                }
                translate([0, -height * 0.3, 0]) {
                    text("2024", size=text_size * 1.5, halign="center", valign="top");
                }
            }
            
        }
    }
}

color("green") {
    difference() {
        linear_extrude(thickness_leaf) {
            translate([leaf_shift_x, -height / 2 + leaf_shift_y, 0]) {
                resize([0, leaf_height, 0], auto=true) {
                    import("leaf.svg", center=true);
                }
            }
        }
        linear_extrude(thickness_leaf) {
            translate([leaf_shift_x - 1, -height / 2 + leaf_shift_y, 0]) {
                resize([0, leaf_height - 5, 0], auto=true) {
                    import("leaf-fibrils.svg", center=true);
                }
            }
        }
    }
    translate([-width/4 + left_acorn_shift_x, left_acorn_shift_y, 0]) {
        resize([0, leaf_height / 5, thickness_leaf + thickness_acorn], auto=true) {
            make_acorn(thickness_acorn, "acorn-left.png", 3);
        }
    }
    translate([width/4 + right_acorn_shift_x, right_acorn_shift_y, 0]) {
        resize([0, leaf_height / 5, thickness_leaf + thickness_acorn], auto=true) {
            make_acorn(thickness_acorn, "acorn-right.png", 4);
        }
    }
    
    translate([0, -height, 0]) {
        onto_circle(height - text_shift, 180 - text_angle, 180 + text_angle) {
            letter("O");
            letter("S");
            letter("A");
            letter("D");
            letter("A");
            letter("");
            letter("U");
            letter("");
            letter("D");
            letter("U");
            letter("B");
            letter("U");
        }
    }

    
}
