

diameter = 5;
distance = 8;
bottom_y = 7;
text_width = 20;
text_distance_y = 10;
text_distance_x = 10;
board_thickness = 3;
letter_thickness = 0.5;
hole_depth = 2;

module make_pegs(count_x, count_y, diameter, height, distance) {
    union() {
        for (x = [0:1:count_x-1]) {
            for (y = [0:1:count_y-1]) {
                translate([x*distance , y*distance, 0]) {
                    cylinder(height, d=diameter);
                }
            }
        }
    }
}

$fn = 20;

intersection() {
    //translate([-15, 58, 0]) cube([38, 18, 50]);
    union() {
        difference() {
            translate([-text_width, 0, 0]) {
                cube([
                    text_width + text_distance_y + 10 * distance,
                    11 * distance + bottom_y + text_distance_x,
                    board_thickness
                ]);
            }
            translate([text_distance_y, bottom_y, board_thickness - hole_depth]) {
                make_pegs(10, 10, diameter, hole_depth + 1, distance);
            }
        }
        linear_extrude(letter_thickness + board_thickness) union() {
            for (counter = [0:1:4]) {
                translate([0, counter * distance * 2 + distance + bottom_y, 0]) {
                    text(str((4-counter) * 20), size = 1.2*distance, halign="right", valign="center");
                }
            }
            for (counter = [0:1:4]) {
                shift_x = counter * distance * 2 + text_distance_y;
                shift_y = bottom_y + 9.5*distance + text_distance_x;
                translate([shift_x, shift_y, 0]) {
                    text(str(counter * 2), size = 1.2*distance, halign="center", valign="center");
                }
            }
        }
    }
}