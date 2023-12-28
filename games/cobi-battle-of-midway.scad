
tile_size = 12;
base_height = 2;

holder_diameter = 2;
holder_height = 15;


fusilage_diameter = 2;
fusilage_length = tile_size * 1.2;
engine_length = 2;
wingspan = tile_size * 1.4;
wing_thickness = 1;
canopy_length = tile_size / 3;

//cylinder(h=base_height, r=tile_size, $fn=6);

$fn = 100;

module aircraft() {
    translate([0, 0, -2]) {
        translate([0, 0, engine_length]) {
            cylinder(h=fusilage_length, r1=fusilage_diameter, r2=fusilage_diameter/2);
        };
        cylinder(h=engine_length, r=fusilage_diameter);
        translate([-wingspan/2, 0, engine_length]) {
            cube([wingspan, wing_thickness, canopy_length]);
        }
        translate([-wingspan/4, 0, fusilage_length - canopy_length + engine_length]) {
            cube([wingspan/2, wing_thickness, canopy_length]);
        }
        translate([-wing_thickness/2, -wing_thickness, fusilage_length]) {
            rotate([90, 180, 90]) {
                cylinder(h=wing_thickness, d=canopy_length, $fn=3);
            }
        }
    }
}

cylinder(h=base_height, r=tile_size, $fn=6);
translate([0, -tile_size/2, base_height + fusilage_diameter/2]) {
    rotate([270, 0, 0]) {
        aircraft();
    }
}
cylinder(h=holder_height, d=holder_diameter);
