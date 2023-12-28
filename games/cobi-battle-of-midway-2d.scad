
tile_size = 14;
base_height = 5;

holder_diameter = 5;
holder_height = 14;

fusilage_diameter = 3;

$fn = 40;

module wing(span, chord, tip_chord_scale=1) {
    tip_chord = chord * tip_chord_scale;
    hull() {
        square([chord, 0.1], center=true);
        translate([tip_chord/2-chord/2, -span/2 + tip_chord/2]) {
            circle(d=tip_chord);
        }
        translate([tip_chord/2-chord/2, span/2 - tip_chord/2]) {
            circle(d=tip_chord);
        }
    }
}

module fuselage(total_length, engine_width, tail_width, engine_length_fraction=0.2) {
    engine_length = total_length * engine_length_fraction;
    fuselage_length = total_length - engine_length;
    tail_offset = (engine_width - tail_width) / 2;
    
    translate([engine_length / 2 - total_length / 2, 0]) {
        square([engine_length, engine_width], center=true);
    }
    translate([engine_length - total_length / 2, -engine_width / 2]) {
        polygon([
            [0, 0],
            [fuselage_length, tail_offset],
            [fuselage_length, tail_offset + tail_width],
            [0, engine_width]
        ]);
    }
}

module rounded_extrusion(extrusion, border=0.5) {
    minkowski() {
        sphere(r=border);
        linear_extrude(extrusion) {
            children();
        }
    }
}

module aircraft(length, wingspan, diameter, propeller, thickness, height, edge_size=0.5) {
    extrusion_size = height - 2 * edge_size;
    raw_wingspan = wingspan - 2 * edge_size;
    
    // Main wing
    rounded_extrusion(extrusion_size, edge_size) {
        translate([-0.1*length, 0]) {
            wing(raw_wingspan, length/4, 0.7);
        }
    }
    
    // Tail
    rounded_extrusion(extrusion_size, edge_size) {
        translate([length/2 - length/12 - edge_size, 0]) {
            rotate([0, 0, 180]) {
                wing(0.3*wingspan, length/6, 0.8);
            }
        }
    }
    
    // Fuselage
    rounded_extrusion(extrusion_size, edge_size) {
        translate([thickness - 2*edge_size, 0]) {
            fuselage(length-thickness-4*edge_size, diameter, 0.5*diameter);
        }
    }
    // Propeller
    rounded_extrusion(extrusion_size, edge_size) {
        translate([-length/2  - edge_size + thickness, -thickness + edge_size]) {
            square([thickness + 2*edge_size, 2*thickness - 2*edge_size]);
        }
    }
    rounded_extrusion(extrusion_size, edge_size) {
        translate([-length/2 + edge_size, -propeller/2 + edge_size]) {
            square([thickness - 2*edge_size, propeller - 2*edge_size]);
        }
    }
}

// https://gist.github.com/anoved/9622826?permalink_comment_id=4384183#gistcomment-4384183
module star(p=5, r1=4, r2=10) {
    s = [
            for(i=[0:p*2]) 
            [
                (i % 2 == 0 ? r1 : r2)*cos(180*i/p),
                (i % 2 == 0 ? r1 : r2)*sin(180*i/p)
            ]
    ];
    
    polygon(s);
}

module pawn_base_frame(size, height, width) {
    difference() {
        cylinder(h=height, r=size, $fn=6);
        translate([0, 0, -1]) {
            cylinder(h=height+2, r=size-width, $fn=6);
        }
    }
}

module pawn_base(size, height, inset_height, inset, ace=true) {
    difference() {
        cylinder(h=height, r=size, $fn=6);
        translate([0, 0, height - inset_height]) {
            linear_extrude(2 * inset_height) {
                if (inset == "star") {
                    rotate([0, 0, 30]) {
                        star(5, 0.32*size, 0.8*size);
                    }
                }
                if (inset == "sun") {
                    circle(d=1.2*size);
                }
            }
        }
        translate([0, 0, height - inset_height]) {
            pawn_base_frame(size+1, height, 0.15*size);
        }
    }
}


module pawn(size, base_height, inset_height, fusilage_diameter, holder_height, holder_diameter, inset) {
    intersection() {
        union() {
            pawn_base(size, base_height, inset_height, inset);
            rotate([0, 0, 30]) {
                translate([0.1*tile_size, 0, 0]) {
                    aircraft(
                        1.2*tile_size,
                        1.4*tile_size,
                        fusilage_diameter,
                        0.7*size,
                        1.5,
                        base_height + 2*inset_height,
                        0.5
                    );
                }
                    //aircraft(1.4*size, 1.4*size, size/4, 0.7*size, 0.4);
            }
            translate([0, 0, inset_height]) {
                minkowski() {
                    sphere(1);
                    cylinder(h=base_height + inset_height + holder_height, d=holder_diameter);
                }
            }
        }
        cylinder(h=base_height + holder_height + 10 * inset_height, r=size, $fn=6);
    }
}

module make_pawn(pawn_type, ace) {
    pawn(
        tile_size,
        base_height * (ace ? 2.5 : 1),
        0.3 * base_height,
        fusilage_diameter,
        holder_height,
        holder_diameter,
        pawn_type
    );
}

pawn_shift = 2.3 * tile_size;

translate([0*pawn_shift, 0*pawn_shift, 0]) make_pawn("star", false);
translate([1*pawn_shift, 0*pawn_shift, 0]) make_pawn("star", true);
translate([0*pawn_shift, 1*pawn_shift, 0]) make_pawn("sun", false);
translate([1*pawn_shift, 1*pawn_shift, 0]) make_pawn("sun", true);
