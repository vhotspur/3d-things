
shaft_diameter = 4.4;
shaft_height = 30;

head_diameter = 10;
head_rounded_corners_radius = 1;
head_height = 3.4;

$fn = 100;

translate([0, 0, head_height/2]) {
    minkowski() {
        cylinder(
            h=head_height - 2*head_rounded_corners_radius,
            d=head_diameter - 2*head_rounded_corners_radius,
            center=true
        );
        sphere(r=head_rounded_corners_radius);
    }
}
cylinder(h=shaft_height+head_height, d=shaft_diameter);
