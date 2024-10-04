print = 2;
$fn = 100;

include <BOSL2/std.scad>

leg_size = [60, 40];
leg_height = 30;
leg_thickness = 12;

leg_padding = 8;
leg_cover_padding = 2;
leg_cover_height = 2;

base_size = [140, 140];
base_height = 50;
base_thickness = 4;
base_wall_thickness_factor = 20;
base_scale_factor = 0.7;

hull_length = 105 + 2*25;
hull_width = 58;
stand_bottom_thickness = 10;
side_thickness = 7;
side_height = 16;
side_shortening = 30;

grip_size = [25, 35, 6];
ejector_size = [25, 45];

rounding_radius = 2;

module make_base_and_leg(base_size, base_height, leg_size, leg_height) {
    prismoid(
        size1=base_size,
        size2=leg_size,
        h=base_height,
        rounding=rounding_radius
    );
    up(base_height) {
        cuboid(
            flatten([leg_size, [leg_height]]),
            anchor=BOTTOM,
            rounding=rounding_radius,
            edges=["Z"]
        );
    }
}

module make_base_padding() {
    up(base_height + leg_height) {
        difference() {
            cuboid(
                flatten([
                    add_scalar(leg_size, -2*leg_padding),
                    [stand_bottom_thickness]
                ]),
                anchor=BOTTOM
            );
            up(stand_bottom_thickness - leg_cover_height) cuboid(
                [
                    leg_size[0] - 2*leg_padding - 2*leg_cover_padding,
                    leg_size[1] - 2*leg_padding - 2*leg_cover_padding,
                    leg_cover_height + 1
                ],
                anchor=BOTTOM
            );
            down(1) cuboid(
                flatten([
                    add_scalar(leg_size, -2*leg_thickness),
                    [leg_height + 2]
                ]),
                anchor=BOTTOM
            );
        }
    }
}

module make_base_with_leg() {
    t2 = 2 * base_wall_thickness_factor;
    h2 = 2 * base_height;
    diff = base_size - leg_size;
    inner_diff_scale = [
        (base_size[0] - t2 / (sin(atan(h2 / diff[0])))) / base_size[0],
        (base_size[1] - t2 / (sin(atan(h2 / diff[1])))) / base_size[1],
        (base_height - base_thickness) / base_height
    ];
    echo(inner_diff_scale);
    inner_diff_scale3 = repeat((base_height - base_thickness) / base_height, 3);
    difference() {
        prismoid(
            size1=base_size,
            size2=leg_size,
            h=base_height,
            rounding=rounding_radius
        );
        if (base_thickness > 0) {
            up(base_thickness) {
                scale(inner_diff_scale) {
                    prismoid(
                        size1=base_size,
                        size2=leg_size,
                        h=base_height + 1,
                        rounding=rounding_radius
                    );
                }
            }
        }
    }
    
    up(base_height) {
        difference() {
            cuboid(
                flatten([leg_size, [leg_height]]),
                anchor=BOTTOM,
                rounding=rounding_radius,
                edges=["Z"]
            );
            if (base_thickness > 0) {
                    prismoid(
                        size1=scale(inner_diff_scale, leg_size),
                        size2=add_scalar(leg_size, -2*leg_thickness),
                        h=leg_height + 1
                    );
            }
        }
    }
            
    make_base_padding();
}

module make_stand() {
    difference() {
        cuboid(
            [hull_length, hull_width + 2*side_thickness, stand_bottom_thickness],
            anchor=BOTTOM,
            rounding=rounding_radius,
            edges=[BOTTOM, "Z"]
        );
        right(hull_length/2 + 1) down(1) {
            cuboid(
                [ejector_size[0] + 1, ejector_size[1], stand_bottom_thickness + 2],
                anchor=BOTTOM + RIGHT,
                rounding=rounding_radius,
                edges=[FORWARD+LEFT, BACK+LEFT]
            );
        }
    }
    up(stand_bottom_thickness) {
        for (param=[
            [BOTTOM + FRONT, hull_width/2, side_shortening],
            [BOTTOM + BACK, -hull_width/2, 0]]
        ) {
            back(param[1]) left(param[2]/2) {
                cuboid(
                    [hull_length - param[2], side_thickness, side_height],
                    anchor=param[0],
                    rounding=rounding_radius,
                    edges=[TOP, "Z"]
                );
            }
        }
        left(hull_length/2) {
            cuboid(
                grip_size,
                rounding=rounding_radius,
                anchor=LEFT + BOTTOM,
                edges=[TOP, "Z"]
            );
        }
    }
}




if ((print == 0) || (print == 1)) {
    make_base_with_leg();
    if (false) {
    if (base_thickness > 0) {
        difference() {
            union() {
                make_base_and_leg(base_size, base_height, leg_size, leg_height);
                make_base_padding();
            }
            up(base_thickness) {
                /*make_base_and_leg(
                    add_scalar(base_size, -4*base_thickness),
                    base_height - base_thickness,
                    add_scalar(leg_size, -2*leg_thickness),
                    leg_height + 1 + stand_bottom_thickness
                );*/
                scale(base_scale_factor) {
                    #make_base_and_leg(base_size, base_height, leg_size, leg_height);
                }
            }
        }
    } else {
        make_base_and_leg(base_size, base_height, leg_size, leg_height);
        make_base_padding();
    }
    }
}

if ((print == 0) || (print == 2)) {
    up(print == 0 ? base_height + leg_height : 0) {
        difference() {
            make_stand();
            down(1) cuboid(
                flatten([add_scalar(leg_size, -2*leg_padding), [stand_bottom_thickness + 2]]),
                anchor=BOTTOM
            );
        }
    }
}

if ((print == 0) || (print == 3)) {
    up(print == 0 ? base_height + leg_height + stand_bottom_thickness: 0) {
        cuboid(
            flatten([
                add_scalar(leg_size, - 2*leg_padding - 2*leg_cover_padding),
                [leg_cover_height]
            ]),
            anchor=TOP
        );
    }
}
