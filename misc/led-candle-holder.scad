
include <BOSL2/std.scad>

bottom_wall = 0.8;
inner_diameter = 38;
side_wall = 1;
total_height = 60;
candle_height = 17;
gallery_width = 4;
gallery_height = 6;
nail_diameter = 1.5;
little_bit = 0.01;

$fa = $preview ? 10 : 0.25;
$fs = $preview ? 10 : 0.5;


tube(
    id=inner_diameter,
    wall=side_wall,
    h=total_height,
    orounding2=side_wall/2,
    anchor=BOTTOM
);
difference() {
    cyl(
        h=bottom_wall,
        d=inner_diameter + 2*side_wall,
        anchor=BOTTOM
    );
    down(little_bit) {
        cyl(
            h=bottom_wall + 2*little_bit,
            d=nail_diameter,
            anchor=BOTTOM
        );
    }
}

up(total_height - candle_height) difference() {
    cyl(
        h=gallery_height,
        d=inner_diameter,
        anchor=TOP
    );
    up(little_bit) {
        cyl(
            h=gallery_height + 2*little_bit,
            d1=inner_diameter,
            d2=inner_diameter - 2*gallery_width,
            anchor=TOP
        );
    }
}
