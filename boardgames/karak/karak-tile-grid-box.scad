/*
 * Simple box for the Karak/Caracassonne tiles grid.
 *
 * Author: Vojtech Horky
 * License: CC BY-SA 4.0
 *
 * The actual tiles grid was created by user timqui and is available at:
 * https://www.printables.com/model/74459-carcassonne-karak-isle-of-skye-tiles-grid/
 *
 */


size = 143;
lock_size = 20;
height = 50;
wall_width = 1.2;
lid_height = 10;
lid_spacing = 0.5;

hole_width = 10;
hole_top_margin = 10;
hole_bottom_margin = 9;
hole_half_count = 3;

space_for_holes = (size - lock_size) / 2;
space_between_holes = 
    (space_for_holes - hole_half_count * hole_width) / (hole_half_count + 1 );
hole_height = height - hole_top_margin - hole_bottom_margin;

module the_box(size, height, lock_size, lock_offset=0) {
    cube([size, size, height]);
    translate([size / 2, lock_offset, 0]) {
        cylinder(h=height, d=lock_size);
    }
    translate([lock_offset, size / 2, 0]) {
        cylinder(h=height, d=lock_size);
    }
}

module the_hole(width, height, thickness) {
    rotate([90, 0, 0]) {
        translate([0, width/2, -thickness/2]) {
            union() {
                cylinder(h=thickness, d=width);
                translate([0, height - width, 0]) cylinder(h=thickness, d=width);
                translate([-width/2, 0, 0]) cube([width, height - width, thickness]);
            }
        }
    }
}

module final_box() {
    difference() {
        translate([-wall_width, -wall_width, -wall_width]) {
            the_box(size + 2*wall_width, height, lock_size + 2*wall_width, wall_width);
        }
        union() {
            the_box(size, height, lock_size);
            for (pair=[[0, 0], [0, size], [90, -size], [90, 0]]) {
                angle = pair[0];
                y_shift= pair[1];
                if (hole_half_count > 0) {
                    for (i=[0:(hole_half_count-1)]) {
                        shift_x = hole_width/2
                            + space_between_holes
                            + (space_between_holes + hole_width) * i;
                        rotate([0, 0, angle]) {
                            translate([shift_x, y_shift, hole_bottom_margin]) {
                                the_hole(hole_width, hole_height, wall_width * 4);
                            }
                        }
                        rotate([0, 0, angle]) {
                            translate([size - shift_x, y_shift, hole_bottom_margin]) {
                                the_hole(hole_width, hole_height, wall_width * 4);
                            }
                        }
                    }
               }
            }
        }
    }
}

module final_lid() {
    shifted_by = -2*wall_width-lid_spacing;
    difference() {
        translate([shifted_by, shifted_by, shifted_by]) {
            // size, height, lock_size, lock_offset=0
            the_box(
              size + 4*wall_width+2*lid_spacing,
              lid_height,
              lock_size + 4*wall_width + 2*lid_spacing,
              2*wall_width + lid_spacing);
        }
        translate([-wall_width-lid_spacing, -wall_width-lid_spacing, -wall_width]) {
            the_box(
                size + 2*wall_width + 2*lid_spacing,
                lid_height,
                lock_size + 2*wall_width + lid_spacing,
                wall_width
            );
        }
    }
}

final_box();
//final_lid();
