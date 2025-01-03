
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

print = 300;

inner_box_unit = 75;
drawer_width = 161;
drawer_segment_front_length = 128;
drawer_segment_middle_length = 129;
drawer_segment_back_length = 130;
drawer_segment_bottom_dovetail_width = 12;
drawer_segment_bottom_dovetail_depth = 8;
drawer_segment_bottom_dovetail_radius = 1;
drawer_segment_side_dovetail_width = 12;
drawer_segment_side_dovetail_depth = 8;
drawer_segment_side_dovetail_radius = 1;
drawer_unit_height = 162/3; // Including spacing!
drawer_actual_height = 28;
drawer_side_wall = 4;
drawer_bottom_wall = 4;
drawer_front_wall = 4;
drawer_back_wall = 4;
drawer_count = 3;
drawer_frame_spacing_half = 0.5;

frame_wall = 3;
frame_depth = 60;
frame_back_wall = 0;
frame_mount_hole_outer_radius = 1;
frame_mount_hole_inner_radius = 4;
frame_mount_hole_offset_z = 4;
frame_mount_hole_offset_side = 0; //25;

rail_height = 3;
rail_width = 3;
rail_skew_length = 2;
rail_offset = 3;

pattern_padding = 5;
pattern_bottom_params = [13, 6, 3, 0] * 0;
pattern_side_params = [13, 6, 3, 0] * 0;
pattern_back_params = [15, 7] * 0;
pattern_drawer_bottom_padding = 6;
pattern_drawer_bottom_params = [24, 12] * 0; //[15, 7] * 1;
pattern_drawer_side_padding = 3;
pattern_drawer_side_params = [15, 7] * 0;
pattern_drawer_back_padding = 3;
pattern_drawer_back_params = [12, 6] * 0;
pattern_drawer_front_params = [15, 7] * 0;

circular_handle_wall = 4;
circular_handle_spacing = 10;
circular_handle_height = 8;



// You probably do not need to change anything below :-)

$fa = $preview ? 10 : 0.5;
$fs = $preview ? 10 : 0.5;

col_normal = "#ccffcc";
col_supports = "#ccccff";
col_no_infill = "#ffcccc";

drawer_length = drawer_segment_front_length + drawer_segment_middle_length + drawer_segment_back_length;

frame_outer_width = drawer_width + 2*drawer_frame_spacing_half + frame_wall*2;
frame_outer_height = drawer_unit_height * drawer_count + frame_wall * 2;



let (
    inner_width = drawer_width - 2 * drawer_side_wall,
    inner_length = drawer_length - (drawer_front_wall + drawer_back_wall),
    boxes_x = floor(inner_width / inner_box_unit),
    boxes_y = floor(inner_length / inner_box_unit)
) {
    echo(format(
        "FRAME: {} wide (twice {}), {} high (twice {})", [
            frame_outer_width, frame_outer_width * 2,
            frame_outer_height, frame_outer_height * 2,
    ]));
    echo(format(
        "DRAWER SIZE: OUTER {} x {}, INNER SPACE {} x {}", [
            drawer_width,
            drawer_length,
            inner_width,
            inner_length,
    ]));
    echo(format(
        "BOXES INSIDE (unit {}): {} x {} (extra space is {} x {})", [
            inner_box_unit,
            boxes_x, boxes_y,
            inner_width - inner_box_unit * boxes_x,
            inner_length - inner_box_unit * boxes_y,
    ]));
}

module make_rail() {
    up(rail_skew_length + rail_offset) {
        cuboid(
            [rail_width, rail_height, frame_depth - 2 * (rail_skew_length + rail_offset)],
            anchor=BOTTOM + FRONT + LEFT
        );
    }
    up(rail_offset) prismoid(
        size1=[0, rail_height],
        size2=[rail_width, rail_height],
        shift=[rail_width/2, 0],
        h=rail_skew_length,
        anchor=BOTTOM + FRONT + LEFT
    );
    up(frame_depth - rail_skew_length - rail_offset) {
        prismoid(
            size1=[rail_width, rail_height],
            size2=[0, rail_height],
            shift=[-rail_width/2, 0],
            h=rail_skew_length,
            anchor=BOTTOM + FRONT + LEFT
        );
    }
}

module make_flat_dovetail(gender, total_width, thickness, size, dovetail_width, dovetail_radius, slope=4) {
    distance = 2 * dovetail_width - 2 * size / slope;
    count = floor(total_width / distance) + 1;

    module one_dovetail() {
        up(thickness/2) xrot(90) {
            dovetail(
                gender,
                width=dovetail_width,
                height=size,
                thickness=thickness,
                radius=dovetail_radius,
                round=true,
                slope=slope
            );
        }
    }

    if (gender == "male") {
        intersection() {
            cuboid([total_width, size, thickness], anchor=BOTTOM+BACK);
            xcopies(distance, count) {
                one_dovetail();
            }
        }
    } else {
        intersection() {
            cuboid([total_width, size, thickness], anchor=BOTTOM+FRONT);
            xcopies(distance, count + 1) {
                one_dovetail();
            }
        }
    }
}

module make_subtractable_pattern(width, height, thickness, padding=0, pattern=[20, 8]) {
    function make_odd(val) = ((val % 2) == 0) ? val + 1 : val;
    if (false) {
        echo(format(
            "Subtractable pattern: {} x {} x {} (pad {}, pattern {})", [
                width, height, thickness,
                padding, pattern
        ]));
    }
    if (pattern[0] * pattern[1] > 0) {
        // Ensure full hexagon is in the middle
        count_x = make_odd(ceil(width / pattern[0]) * 2);
        count_y = make_odd(ceil(height / (sqrt(3) * pattern[0] / 2)));
        echo(format("counts: {} {}", [count_x, count_y]));
        move([width/2, height/2, -1]) intersection() {
            cube([width - padding*2, height - padding*2, thickness], center=true);
            grid_copies(n=[count_x, count_y], spacing=pattern[0], stagger=true) {
                down(thickness / 2 + 1) linear_extrude(thickness + 2) zrot(90) hexagon(pattern[1]);
            }
       }
   }
}

module make_frame() {
    module bottom_pattern() {
       left(frame_outer_width/2) xrot(90) down(1) make_subtractable_pattern(
           frame_outer_width,
           frame_depth,
           frame_wall,
           pattern_padding,
           pattern_bottom_params
       );
    }

    module side_pattern() {
        zrot(90) xrot(90) make_subtractable_pattern(
           drawer_unit_height,
           frame_depth,
           frame_wall,
           pattern_padding,
           pattern_side_params
       );
    }

    difference() {
        rect_tube(
            size=[frame_outer_width, frame_outer_height],
            wall=frame_wall,
            height=frame_depth,
            anchor=BOTTOM + FRONT
        );
        union() {
            bottom_pattern();
            back(frame_outer_height - frame_wall) bottom_pattern();
            
            for (i = [0:drawer_count]) {
                back(i*drawer_unit_height + frame_wall) {
                    left(frame_outer_width/2-1) side_pattern();
                    right(frame_outer_width/2-1) side_pattern();
                }
            }
        }
        if (frame_mount_hole_offset_side > 0) {
            cyl_params = [
                [frame_mount_hole_outer_radius, frame_mount_hole_inner_radius, -1, 0, 1, -1, 0],
                [frame_mount_hole_inner_radius, frame_mount_hole_outer_radius, +1, 0, 1, -1, 1],
                [frame_mount_hole_outer_radius, frame_mount_hole_inner_radius, -1, 1, -1, 1, 0],
                [frame_mount_hole_inner_radius, frame_mount_hole_outer_radius, +1, 1, -1, 1, 1]
            ];
            xshift = (frame_outer_width/2 - frame_wall/2);
            for (param = cyl_params) {
                translate([
                        param[2] * xshift,
                        param[3] * frame_outer_height + param[4] * frame_mount_hole_offset_side,
                        frame_mount_hole_offset_z]) {
                    xcyl(l=frame_wall, r1=param[0], r2=param[1]);
                }
                translate([
                        param[5] * xshift + param[4] * frame_mount_hole_offset_side,
                        param[6] * (frame_outer_height - frame_wall),
                        frame_mount_hole_offset_z]) {
                    ycyl(l=frame_wall, r1=param[0], r2=param[1], anchor=FRONT);
                }
            }
        }
    }

    if (drawer_count > 1) {
        rail_bottoms = [
            for (i = [1:(drawer_count) - 1])
            i * drawer_unit_height + frame_wall - rail_height
        ];
        rail_shift_x = frame_outer_width/2 - frame_wall;
        for (y = [ for (i = rail_bottoms) i ]) {
            echo(format("Rail bottoms at {} ({} from bottom, unit is {})", [y, y - frame_wall, drawer_unit_height]));
            move([-rail_shift_x, y, 0]) make_rail();
            move([rail_shift_x, y, 0]) xflip() make_rail();
        }
    }

    if (frame_back_wall > 0) {
        difference() {
            cube(
                [frame_outer_width, frame_outer_height, frame_back_wall],
                anchor=TOP + FRONT
            );
            left(frame_outer_width/2) down(1) make_subtractable_pattern(
                frame_outer_width,
                frame_outer_height,
                frame_wall,
                pattern_padding,
                pattern_back_params
            );
        }
    }
}

module make_chamfered_circular_handle(chamfer=1) {
    outer_radius_partial = circular_handle_wall + circular_handle_spacing;
    d = outer_radius_partial + (drawer_width * drawer_width) / (4 * outer_radius_partial);
    intersection() {
        back(d/2 - outer_radius_partial) {
            difference() {
                cyl(height=circular_handle_height, d=d, chamfer=chamfer, anchor=BOTTOM);
                cyl(height=circular_handle_height, d=d - 2*circular_handle_wall, chamfer=-chamfer, anchor=BOTTOM);
            }
        }
        cuboid(
            [drawer_width, d, circular_handle_height],
            anchor=BOTTOM + BACK,
        );
    }
}

module make_circular_handle() {
    make_chamfered_circular_handle(0);
}

module make_drawer_segment_u_shape(
        height, width,
        bottom_thickness, side_wall_thickness,
        length,
        connection_depth_front=0,
        connection_depth_back=0,
        connection_offset=0,
        connection_vertical_front_shift=undef,
        connection_vertical_back_shift=undef) {

    module vertical_dovetail(angle) {
        back(0) zrot(90) yrot(angle) {
            dovetail(
                "male",
                width=drawer_segment_side_dovetail_width,
                height=drawer_segment_side_dovetail_depth,
                thickness=width + 2,
                radius=drawer_segment_bottom_dovetail_radius,
                round=false,
                slope=4
            );
        }
    }

    module side_pattern() {
        front_shift = connection_depth_front > 0 ? drawer_segment_side_dovetail_depth : 0;
        back_shift = connection_depth_back > 0 ? drawer_segment_side_dovetail_depth : 0;
        actual_length = length - front_shift - back_shift;
        up(bottom_thickness) back(front_shift) zrot(90) xrot(90) make_subtractable_pattern(
            actual_length,
            height - bottom_thickness,
            side_wall_thickness + 2,
            pattern_drawer_side_padding,
            pattern_drawer_side_params
        );
    }

    difference() {
        union() {
            cuboid([width, length, bottom_thickness], anchor=BOTTOM + FRONT);
            xcopies(width - side_wall_thickness, 2) {
                cuboid([side_wall_thickness, length, height], anchor=BOTTOM + FRONT);
            }
        }
        union() {
            if (pattern_drawer_bottom_params[0] > 0) {
                left(width/2 - side_wall_thickness) up(bottom_thickness/2 + 1) back(connection_depth_front) make_subtractable_pattern(
                    width - 2*side_wall_thickness,
                    length - connection_depth_front - connection_depth_back,
                    bottom_thickness + 2,
                    pattern_drawer_bottom_padding,
                    pattern_drawer_bottom_params
                );
            }

            if (pattern_drawer_side_params[0] > 0) {
                left(width/2 - side_wall_thickness + 1) side_pattern();
                right(width/2 - 1) side_pattern();
            }

            if (connection_depth_back) {
                back(length + 1) down(1) cuboid([
                    width - side_wall_thickness * 2 - connection_offset * 2,
                    connection_depth_back + 1,
                    bottom_thickness * 2
                ], anchor=BOTTOM + BACK);
            }
            if (connection_depth_front) {
                fwd(1) down(1) cuboid([
                    width - side_wall_thickness * 2 - connection_offset * 2,
                    connection_depth_front + 1,
                    bottom_thickness * 2
                ], anchor=BOTTOM + FRONT);
            }

            if (connection_vertical_front_shift != undef) {
                up(connection_vertical_front_shift) vertical_dovetail(90);
            }
            if (connection_vertical_back_shift != undef) {
                back(length) up(connection_vertical_back_shift) vertical_dovetail(270);
            }
        }
    }
}

module make_drawer_front_side() {
    cuboid([drawer_width, drawer_front_wall, drawer_unit_height], anchor=BOTTOM + FRONT);
    make_chamfered_circular_handle();
}

module make_drawer_back_side() {
    difference() {
        cuboid([drawer_width, drawer_back_wall, drawer_actual_height], anchor=BOTTOM + FRONT);
        if (pattern_drawer_back_params[0] > 0) {
            up(drawer_bottom_wall) back(1) left(drawer_width / 2 - drawer_side_wall) xrot(90) make_subtractable_pattern(
                drawer_width - 2*drawer_side_wall,
                drawer_actual_height - drawer_bottom_wall,
                drawer_bottom_wall + 2,
                pattern_drawer_back_padding,
                pattern_drawer_back_params
            );
        }
    }
}

module make_drawer_side_connection_supports_shape(anchor=FRONT) {
    cuboid(
        [drawer_side_wall, drawer_segment_bottom_dovetail_depth, drawer_actual_height],
        anchor=BOTTOM + anchor
    );
}

module make_drawer_segment_front() {
    back(drawer_front_wall) make_drawer_segment_u_shape(
        drawer_actual_height, drawer_width,
        drawer_bottom_wall, drawer_side_wall,
        drawer_segment_front_length - drawer_front_wall,
        0,
        drawer_segment_bottom_dovetail_depth/2,
        drawer_segment_bottom_dovetail_depth,
        undef,
        drawer_actual_height/2
    );
    back(drawer_segment_front_length - drawer_segment_bottom_dovetail_depth/2) make_flat_dovetail(
        "female",
        drawer_width - 2*drawer_side_wall - drawer_segment_bottom_dovetail_depth*2,
        drawer_bottom_wall,
        drawer_segment_bottom_dovetail_depth,
        drawer_segment_bottom_dovetail_width,
        drawer_segment_bottom_dovetail_radius
    );
    make_drawer_front_side();
}

module make_drawer_side_connection_supports(anchor=BACK) {
    left(drawer_width/2) make_drawer_side_connection_supports_shape(anchor + LEFT);
    right(drawer_width/2) make_drawer_side_connection_supports_shape(anchor + RIGHT);
}

module make_drawer_segment_front_supports() {
    back(drawer_segment_front_length) make_drawer_side_connection_supports();
}

module make_drawer_segment_front_no_infill() {
    up(drawer_actual_height) {
        cuboid([drawer_width, drawer_front_wall, drawer_unit_height - drawer_actual_height], anchor=BOTTOM + FRONT);
    }
}

module make_drawer_segment_middle() {
    make_drawer_segment_u_shape(
        drawer_actual_height, drawer_width,
        drawer_bottom_wall, drawer_side_wall,
        drawer_segment_middle_length,
        drawer_segment_bottom_dovetail_depth/2,
        drawer_segment_bottom_dovetail_depth/2,
        drawer_segment_bottom_dovetail_depth,
        drawer_actual_height/2,
        drawer_actual_height/2
    );
    back(drawer_segment_bottom_dovetail_depth/2) make_flat_dovetail(
        "male",
        drawer_width - 2*drawer_side_wall - drawer_segment_bottom_dovetail_depth*2,
        drawer_bottom_wall,
        drawer_segment_bottom_dovetail_depth,
        drawer_segment_bottom_dovetail_width,
        drawer_segment_bottom_dovetail_radius
    );
    back(drawer_segment_middle_length - drawer_segment_bottom_dovetail_depth/2) make_flat_dovetail(
        "female",
        drawer_width - 2*drawer_side_wall - drawer_segment_bottom_dovetail_depth*2,
        drawer_bottom_wall,
        drawer_segment_bottom_dovetail_depth,
        drawer_segment_bottom_dovetail_width,
        drawer_segment_bottom_dovetail_radius
    );
}

module make_drawer_segment_middle_supports() {
    back(0) make_drawer_side_connection_supports(FRONT);
    back(drawer_segment_middle_length) make_drawer_side_connection_supports();
}

module make_drawer_segment_back() {
    make_drawer_segment_u_shape(
        drawer_actual_height, drawer_width,
        drawer_bottom_wall, drawer_side_wall,
        drawer_segment_back_length - drawer_back_wall,
        drawer_segment_bottom_dovetail_depth/2,
        0,
        drawer_segment_bottom_dovetail_depth,
        drawer_actual_height/2,
        undef
    );
    back(drawer_segment_bottom_dovetail_depth/2) make_flat_dovetail(
        "male",
        drawer_width - 2*drawer_side_wall - drawer_segment_bottom_dovetail_depth*2,
        drawer_bottom_wall,
        drawer_segment_bottom_dovetail_depth,
        drawer_segment_bottom_dovetail_width,
        drawer_segment_bottom_dovetail_radius
    );
    back(drawer_segment_back_length - drawer_back_wall) make_drawer_back_side();
}

module make_drawer_segment_back_supports() {
    make_drawer_side_connection_supports(FRONT);
}


module make_drawer() {
    back(drawer_front_wall) make_drawer_segment_u_shape(
        drawer_actual_height, drawer_width,
        drawer_bottom_wall, drawer_side_wall,
        drawer_length - drawer_back_wall - drawer_front_wall
    );
    make_drawer_front_side();
    back(drawer_length - drawer_back_wall) make_drawer_back_side();
}


if (print == 100) {
    make_frame();
}

if (print == 200) {
    make_drawer();
}

if (print == 300) {
    color("#ccffcc") make_drawer_segment_front();
    up(1) back(drawer_segment_front_length) color("#ccccff") make_drawer_segment_middle();
    up(2) back(drawer_segment_front_length + drawer_segment_middle_length) color("#ffcccc") make_drawer_segment_back();
}

if (print == 310) {
    color(col_normal) make_drawer_segment_front();
    color(col_supports) make_drawer_segment_front_supports();
    color(col_no_infill) make_drawer_segment_front_no_infill();
}
if (print == 311) {
    make_drawer_segment_front();
}
if (print == 312) {
    make_drawer_segment_front_supports();
}
if (print == 313) {
    make_drawer_segment_front_no_infill();
}

if (print == 320) {
    color(col_normal) make_drawer_segment_middle();
    color(col_supports) make_drawer_segment_middle_supports();
}
if (print == 321) {
    make_drawer_segment_middle();
}
if (print == 322) {
    make_drawer_segment_middle_supports();
}

if (print == 330) {
    color(col_normal) make_drawer_segment_back();
    color(col_supports) make_drawer_segment_back_supports();
}
if (print == 331) {
    make_drawer_segment_back();
}
if (print == 332) {
    make_drawer_segment_back_supports();
}

if (print == 350) {
    zrot_copies([0, 180]) {
        xrot(90) {
            dovetail(
                "male",
                width=drawer_segment_side_dovetail_width,
                height=drawer_segment_side_dovetail_depth,
                thickness=drawer_side_wall,
                radius=drawer_segment_side_dovetail_radius,
                round=false,
                slope=4
            );
        }
    }
}

if (print == 400) {
    color("#ccffcc") make_flat_dovetail("male", 220, 3, 10, 16);
    fwd(10) color("#ccccff") make_flat_dovetail("female", 220, 3, 10, 16);
}

if (print == 500) {
    make_drawer_segment_u_shape(
        15, 40,
        3, 2,
        40,
        50,
        5
    );
}
if (print == 501) {
    make_subtractable_pattern(128, 22, 2); // 135 38
}


//make_rail();

//left(drawer_width/2) xrot(90) make_subtractable_pattern(drawer_width, frame_depth, frame_wall, pattern_padding);
