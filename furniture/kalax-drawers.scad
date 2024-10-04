
include <BOSL2/std.scad>

print = 200;

drawer_width = 80;
drawer_length = 120;
drawer_unit_height = 30 + 1/3; // Including spacing!
drawer_actual_height = 25;
drawer_side_wall = 2;
drawer_bottom_wall = 2;
drawer_front_wall = 2;
drawer_count = 2;
drawer_frame_spacing_half = 0.5;

frame_wall = 2;
frame_depth = 120;
frame_back_wall = 2;

rail_height = 3;
rail_width = 3;
rail_skew_length = 6;

pattern_padding = 5;
pattern_bottom_params = [15, 7] * 1;
pattern_side_params = [15, 7] * 1;
pattern_back_params = [15, 7] * 1;
pattern_drawer_bottom_params = [15, 7] * 1;
pattern_drawer_side_params = [15, 7] * 1;
pattern_drawer_back_params = [15, 7] * 1;
pattern_drawer_front_params = [15, 7] * 0;

circular_handle_wall = 4;
circular_handle_spacing = 10;
circular_handle_height = 8;

$fn = 100;

//drawer_width = 161;
//drawer_length = 130;
//drawer_unit_height = 55 + 1/3; // Including spacing!
//drawer_actual_height = 30;
//drawer_side_wall = 4;
//drawer_bottom_wall = 4;
//drawer_front_wall = 4;
//drawer_count = 3;
//drawer_frame_spacing_half = 0.5;
//
//frame_wall = 3;
//frame_depth = 80;
//
//rail_height = 5;
//rail_width = 5;
//rail_skew_length = 5;
//
//pattern_padding = 10;
//pattern_bottom_params = [20, 10] * 1;
//pattern_side_params = [20, 10] * 1;


frame_outer_width = drawer_width + 2*drawer_frame_spacing_half + frame_wall*2;
frame_outer_height = drawer_unit_height * drawer_count;


echo(format("FRAME: {} wide, {} high", [frame_outer_width, frame_outer_height]));

module make_rail() {
    up(rail_skew_length) {
        cuboid(
            [rail_width, rail_height, frame_depth - 2 * rail_skew_length],
            anchor=BOTTOM + FRONT + LEFT
        );
    }
    prismoid(
        size1=[0, rail_height],
        size2=[rail_width, rail_height],
        shift=[rail_width/2, 0],
        h=rail_skew_length,
        anchor=BOTTOM + FRONT + LEFT
    );
    up(frame_depth - rail_skew_length) {
        prismoid(
            size1=[rail_width, rail_height],
            size2=[0, rail_height],
            shift=[-rail_width/2, 0],
            h=rail_skew_length,
            anchor=BOTTOM + FRONT + LEFT
        );
    }
}

module make_subtractable_pattern(width, height, thickness, padding=0, pattern=[20, 8]) {
    if (pattern[0] * pattern[1] > 0) {
        move([width/2, height/2, -thickness]) intersection() {
            cube([width - padding*2, height - padding*2, thickness * 4], center=true);
            grid_copies(size=[width, height], spacing=pattern[0], stagger=true) {
                linear_extrude(thickness*4) zrot(90) hexagon(pattern[1]);
                //(d=20, h=thickness + 2);
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
    }
    
    if (drawer_count > 1) {
        rail_tops = [
            for (i = [1:(drawer_count) - 1])
            i * drawer_unit_height + frame_wall
        ];
        rail_shift_x = frame_outer_width/2 - frame_wall;
        for (y = [ for (i = rail_tops) i - rail_height]) {
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

module make_circular_handle() {
    outer_radius_partial = circular_handle_wall + circular_handle_spacing;
    d = outer_radius_partial + (drawer_width * drawer_width) / (4 * outer_radius_partial);
    intersection() {
        back(d/2 - outer_radius_partial) {
            tube(h=circular_handle_height, od=d, wall=circular_handle_wall, anchor=BOTTOM);
        }
        cuboid(
            [drawer_width, d, circular_handle_height],
            anchor=BOTTOM + BACK,
        );
    }
}

module make_drawer() {
    difference() {
        cuboid(
            [drawer_width, drawer_length, drawer_actual_height],
            anchor=BOTTOM + FRONT
        );
        union() {
            up(drawer_bottom_wall) {
                back(drawer_front_wall) {
                    cuboid(
                        [
                            drawer_width - 2*drawer_side_wall,
                            drawer_length - drawer_side_wall - drawer_front_wall,
                            drawer_actual_height
                        ],
                        anchor=BOTTOM + FRONT
                    );
                }
            }
            left(drawer_width/2) {
                up(1) make_subtractable_pattern(
                    drawer_width,
                    drawer_length,
                    drawer_bottom_wall,
                    pattern_padding,
                    pattern_drawer_bottom_params
                );
            }
            if (pattern_drawer_side_params[0] > 0) {
                left(drawer_width/2 - 1) zrot(90) xrot(90) make_subtractable_pattern(
                    drawer_length,
                    drawer_actual_height,
                    drawer_side_wall,
                    pattern_padding,
                    pattern_drawer_side_params
                );
                right(drawer_width/2 + 1 - drawer_side_wall) zrot(90) xrot(90) make_subtractable_pattern(
                    drawer_length,
                    drawer_actual_height,
                    drawer_side_wall,
                    pattern_padding,
                    pattern_drawer_side_params
                );
            }
            if (pattern_drawer_back_params[0] > 0) {
                back(drawer_length - 1) left(drawer_width/2) xrot(90) make_subtractable_pattern(
                    drawer_width,
                    drawer_actual_height,
                    drawer_side_wall,
                    pattern_padding,
                    pattern_drawer_back_params
                );
            }
            if (pattern_drawer_front_params[0] > 0) {
                back(1) left(drawer_width/2) xrot(90) make_subtractable_pattern(
                    drawer_width,
                    drawer_actual_height,
                    drawer_side_wall,
                    pattern_padding,
                    pattern_drawer_front_params
                );
            }
        }
    }
    make_circular_handle();
}



if (print == 100) {
    make_frame();
}

if (print == 200) {
    make_drawer();
}
//make_rail();

//left(drawer_width/2) xrot(90) make_subtractable_pattern(drawer_width, frame_depth, frame_wall, pattern_padding);