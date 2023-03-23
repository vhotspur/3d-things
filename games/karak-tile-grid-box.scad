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
lock_size = 15;
height = 50;
wall_width = 1;

module the_box(size, height, lock_size, lock_offset=0) {
    cube([size, size, height]);
    translate([size / 2, lock_offset, 0]) {
        cylinder(h=height, d=lock_size);
    }
    translate([lock_offset, size / 2, 0]) {
        cylinder(h=height, d=lock_size);
    }
}

difference() {
    translate([-wall_width, -wall_width, -wall_width]) {
        the_box(size + 2*wall_width, height, lock_size + 2*wall_width, wall_width);
    }
    the_box(size, height, lock_size);
}
