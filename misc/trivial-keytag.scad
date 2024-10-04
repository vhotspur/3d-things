$fn = 50;
linear_extrude(0.5)  difference() {
    union() {
        circle(d = 14);
        translate([0, -7]) square([45, 14]);
    }
    circle(d = 5);
    translate([34, -4]) square(8);
}
linear_extrude(2) translate([5, 0]) text("TAG", size=6, halign="left", valign="center");
