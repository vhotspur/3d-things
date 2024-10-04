
union() {
    difference() {
        cube([80, 80, 30]);
        translate([1,1,1]) {
            cube([78, 78, 30]);
        };
    };
    intersection() {
        translate([-1, -1, 0]) cube([82, 82, 62]);
        translate([40, 80, -25]) {
            rotate([90, 0, 0]) {
                cylinder(h=80, r=30, $fn=100);
            }
        }
    };
}
