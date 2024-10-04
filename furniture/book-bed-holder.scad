$fn = 50;

module cube_with_round_edges(x, y, z, radius) {
    translate([radius, radius, radius]) hull() {
        sphere(radius);
        translate([0, 0, z-2*radius]) sphere(radius);
        translate([x-2*radius, 0, 0]) sphere(radius);
        translate([x-2*radius, y-2*radius, 0]) sphere(radius);
        translate([0, y-2*radius, 0]) sphere(radius);
        translate([x-2*radius, 0, z-2*radius]) sphere(radius);
        translate([x-2*radius, y-2*radius, z-2*radius]) sphere(radius);
        translate([0, y-2*radius, z-2*radius]) sphere(radius);
    }
}

edge_radius = 2;
thickness = 7;
peg_size = 3;
peg_height = 5;
peg_distance = 32;

bed_thickness = 25;
bed_overhang = 55;
total_height = 150;
book_thickness = 35;
book_overhang = 100;

/*
bed_thickness = 7;
bed_overhang = 20;
total_height = 50;
book_thickness = 10;
book_overhang = 20;
*/

module board(width, depth, height) {
    cube_with_round_edges(width, depth, height, edge_radius);
}

module book_holder(size) {
    translate([0, 0, size]) rotate([0, 90, 0]) {
        board(size, book_thickness + 2*thickness, thickness);
        board(size, thickness, book_overhang + thickness);
        translate([0, book_thickness + thickness, 0]) {
            board(size, thickness, total_height);
        }
        translate([0, book_thickness + thickness, total_height - thickness]) {
            board(size, bed_thickness + 2*thickness, thickness);
        }
        translate([0, book_thickness + bed_thickness + 2*thickness, total_height - thickness - bed_overhang]) {
            board(size, thickness, bed_overhang + thickness);
        }
    }
}

function get_pegs_for_edge(edge_size, distance) = [
    for (i = [0:1:(floor(edge_size / distance)-1)])
    [i*distance + (edge_size - peg_distance * (floor(edge_size / distance) - 1)) / 2, 0]
];
    
function list_swap_x_y(coords) = [
    for (i = coords) [i[1], i[0]]
];
function list_add_to_y(coords, shift_y) = [
    for (i = coords) [i[0], i[1] + shift_y]
];
function list_add_to_x(coords, shift_x) = [
    for (i = coords) [i[0] + shift_x, i[1]]
];
function list_add_to(coords, shifts) = [
    for (i = coords) [i[0] + shifts[0], i[1] + shifts[1]]
];
    
function get_all_peg_positions() = concat(
    get_pegs_for_edge(book_overhang, peg_distance),
    list_swap_x_y(get_pegs_for_edge(book_thickness + thickness, peg_distance)),
    list_add_to(get_pegs_for_edge(total_height - thickness, peg_distance), [0, book_thickness + thickness]),
    list_add_to(
        list_swap_x_y(get_pegs_for_edge(book_thickness + thickness, peg_distance)),
        [total_height - thickness, book_thickness + thickness/2]
    ),
    list_add_to(
        get_pegs_for_edge(bed_overhang + thickness, peg_distance),
        [total_height - bed_overhang - 3*thickness/2, book_thickness + bed_thickness + 2*thickness]
    ),
    []
);

module make_full(height) {
    book_holder(height);
}

module make_right(height) {
    union() {
        intersection() {
            cube([total_height, bed_thickness + book_thickness + 3*thickness, height]);
            book_holder(height * 2);
        }
        for (i = get_all_peg_positions()) {
            translate([i[0] + thickness/2, i[1] + thickness/2, height]) {
                cylinder(peg_height, d=peg_size);
            }
        }
    }
}

module make_middle(height) {
    difference() {
        translate([0, 0, -edge_radius]) intersection() {
            translate([0, 0, edge_radius]) {
                cube([total_height, bed_thickness + book_thickness + 3*thickness, height]);
            }
            book_holder(height + 2*edge_radius);
        }
        for (i = get_all_peg_positions()) {
            translate([i[0] + thickness/2, i[1] + thickness/2, -1]) {
                hull() {
                    cylinder(peg_height+1, d=peg_size);
                    translate([0, 0, (peg_height+1)*1.1]) sphere(d=peg_size);
                }
            }
        }
    }
    for (i = get_all_peg_positions()) {
        translate([i[0] + thickness/2, i[1] + thickness/2, height]) {
            cylinder(peg_height, d=peg_size);
        }
    }
}

module make_left(height) {
    difference() {
        translate([0, 0, -edge_radius]) intersection() {
            translate([0, 0, edge_radius]) {
                cube([total_height, bed_thickness + book_thickness + 3*thickness, height]);
            }
            book_holder(height + edge_radius);
        }
        for (i = get_all_peg_positions()) {
            translate([i[0] + thickness/2, i[1] + thickness/2, -1]) {
                hull() {
                    cylinder(peg_height+1, d=peg_size);
                    translate([0, 0, (peg_height+1)*1.1]) sphere(d=peg_size);
                }
            }
        }
    }
}


translate([0, 50, 0])
make_right(90);
make_middle(90);
translate([0, 130, 0])
make_left(90);
