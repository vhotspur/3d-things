

bar_width = 70;
bar_depth = 55;
bar_cut_corner_width = 5;
bar_cut_corner_depth = 3;
bar_thickness = 10;
bar_height = 10;
thickness = 5;

module base_polygon(extra_width=0) {
    polygon([
        [0, 0],
        [bar_width + extra_width - bar_cut_corner_width, 0],
        [bar_width + extra_width , bar_cut_corner_depth],
        [bar_width + extra_width , bar_depth - bar_cut_corner_depth],
        [bar_width + extra_width - bar_cut_corner_width, bar_depth],
        [0, bar_depth]
    ]);
}

module base_hull(extra_depth=0, extra_width=0) {
    translate([-extra_width, 0, -extra_depth])
    intersection() {
        linear_extrude(bar_height + bar_thickness + extra_depth + extra_width * (bar_height + bar_thickness)/ bar_width){
            base_polygon(extra_width);
        }
        union() {
            cube([bar_width + extra_width, bar_depth, bar_thickness+extra_depth]);
            translate([0, bar_depth, bar_thickness+ extra_depth]) rotate([90, 0, 0]) {
                linear_extrude(bar_depth) {
                    polygon([
                        [0, 0],
                        [0, (bar_height) * (bar_width + extra_width) / bar_width],
                        [bar_width + extra_width, 0],
                    ]);
                }
            }
        }
    }
}

if (true) {
    bar_hypotenuse = sqrt(bar_height * bar_height + bar_width * bar_width);
    thickness_on_height = bar_hypotenuse * thickness / bar_width;
    thickness_on_width = bar_width * (bar_height + bar_thickness + thickness_on_height) / bar_height;
    echo(bar_hypotenuse);
    echo(thickness_on_height);
    echo(thickness_on_width);
rotate([0, 180-atan((bar_height)/( bar_width)), 0])
difference() {
    translate([0, -thickness, 0]) {
        resize([
                thickness_on_width,
                bar_depth + 2*thickness,
                bar_height + bar_thickness + thickness_on_height
            ]) {
            base_hull();
        }
    } //*/
    base_hull(0, 0);
    /*translate([-1, bar_depth + 2*thickness, -1]) rotate([90, 0, 0]) {
        linear_extrude(bar_depth + 4*thickness) {
            polygon([
                [0, 0],
                [0, bar_width + bar_depth],
                [bar_width + bar_depth, bar_width + bar_depth]
            ]);
        }
    }//*/
}
}

//base_hull(10, 50);
