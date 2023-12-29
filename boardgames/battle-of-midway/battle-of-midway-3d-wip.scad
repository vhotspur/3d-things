
tile_size = 14;
base_height = 4;

holder_diameter = 2;
holder_height = 15;

fusilage_diameter = 4;

$fn = 50;



module wing(span, chord, enter_thickness, trail_thickness, trail_shift=0) {
    rotate([90, 0, 0]) {
        translate([-chord/2 + enter_thickness/2, 0, -span/2]) {
            hull() {
                translate([0, 0, enter_thickness/2]) {
                    sphere(d=enter_thickness);
                }
                translate([0, 0, span - enter_thickness/2]) {
                    sphere(d=enter_thickness);
                }
                translate([chord - enter_thickness/2 - trail_thickness/2, trail_shift, trail_thickness/2]) {
                    sphere(d=trail_thickness);
                }
                translate([chord - enter_thickness/2 - trail_thickness/2, trail_shift, span - trail_thickness/2]) {
                    sphere(d=trail_thickness);
                }
            }
        }
    }
}


module aircraft(total_length, wingspan, fusilage_diameter, propeller_diameter, propeller_thickness) {
    wing_thickness_primary = fusilage_diameter/4;
    wing_thickness_secondary = fusilage_diameter/6;
    wing_chord_secondary = total_length/5;
    engine_length = total_length/5;
    fusilage_length = total_length-2*propeller_thickness;
    fusilage_start_x = -total_length/2 + 2*propeller_thickness;
    
    // Fusilage (front without narrowing to represent engine)
    translate([fusilage_start_x + engine_length, 0, 0]) {
        rotate([0, 90, 0]) {
            cylinder(h=fusilage_length - engine_length, d1=fusilage_diameter, d2=fusilage_diameter/3);
        }
    }
    translate([fusilage_start_x, 0, 0]) {
        rotate([0, 90, 0]) {
            cylinder(h=engine_length, d=fusilage_diameter);
        }
    }
    // Canopy
    hull() {
        translate([-total_length/4, 0, 0.5*fusilage_diameter]) {
            sphere(d=0.7*fusilage_diameter);
        }
        translate([-total_length/4 + fusilage_diameter/2, 0, 0.5*fusilage_diameter]) {
            sphere(d=0.6*fusilage_diameter);
        }
        translate([total_length/3, 0, 0]) {
            sphere(d=fusilage_diameter/4);
        }
        translate([-total_length/4, 0, 0]) {
            sphere(d=0.7*fusilage_diameter);
        }
    }
    // Main wings
    translate([-total_length/2 + 1.5*total_length/5, 0, -fusilage_diameter/4]) {
        wing(wingspan, total_length/4, wing_thickness_primary, wing_thickness_primary/2, -fusilage_diameter/20);
    }
    // Tail wings
    translate([total_length/2 - .5*total_length/5, 0, 0]) {
        wing(wingspan/2, wing_chord_secondary, wing_thickness_secondary, wing_thickness_secondary/2, 0);
    }
    // Rudder
    hull() {
        translate([total_length/2 - wing_thickness_secondary, 0, propeller_diameter/3]) {
            sphere(d=wing_thickness_secondary);
        }
        translate([total_length/2 - wing_thickness_secondary, 0, 0]) {
            sphere(d=wing_thickness_secondary);
        }
        translate([total_length/2 - wing_thickness_secondary - wing_chord_secondary, 0, 0]) {
            sphere(d=wing_thickness_secondary);
        }
    }
    // Propeller
    translate([-total_length/2, 0, 0]) {
        rotate([0, 90, 0]) {
            cylinder(h=propeller_thickness, d=propeller_diameter);
            translate([0, 0, propeller_thickness]) {
                cylinder(h=propeller_thickness, d=fusilage_diameter/5);
            }
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
                    star(5, 0.333*size, 0.8*size);
                }
                if (inset == "sun") {
                    circle(d=1.2*size);
                }
            }
        }
        translate([0, 0, height - inset_height]) {
            pawn_base_frame(size+1, height, 0.1*size);
        }
    }
}


module pawn(size, base_height, fusilage_diameter, holder_height, holder_diameter, inset) {
    intersection() {
        union() {
            pawn_base(size, base_height, base_height*0.1, inset);
            translate([0, 0, base_height + 0.2*fusilage_diameter]) {
                rotate([0, 5, 0]) {
                    aircraft(1.4*size, 1.4*size, size/4, 0.7*size, 0.4);
                }
            }
            translate([0, 0, base_height]) {
                cylinder(h=holder_height-holder_diameter/2, d=holder_diameter);
                translate([0, 0, holder_height-holder_diameter/2]) {
                    sphere(d=holder_diameter);
                }
            }
        }
        cylinder(h=base_height + holder_height, r=size, $fn=6);
    }
}

module make_pawn(pawn_type, ace) {
    pawn(
        tile_size,
        base_height * (ace ? 2 : 1),
        fusilage_diameter,
        holder_height,
        holder_diameter,
        pawn_type
    );
}

pawn_shift = 2.3 * tile_size;

translate([0*pawn_shift, 0*pawn_shift, 0]) make_pawn("star", false);
//translate([1*pawn_shift, 0*pawn_shift, 0]) make_pawn("star", true);
translate([0*pawn_shift, 1*pawn_shift, 0]) make_pawn("sun", false);
//translate([1*pawn_shift, 1*pawn_shift, 0]) make_pawn("sun", true);

