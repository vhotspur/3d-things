$fn = 50;

module make_peg(peg_size, peg_height, peg_top, peg_bottom, peg_offset, peg_extra_width) {
    linear_extrude(peg_size) {
        difference() {
            offset(peg_offset) {
                polygon([
                    [-peg_extra_width, -peg_extra_width],
                    [peg_extra_width + peg_bottom, -peg_extra_width],
                    [peg_bottom - (peg_bottom - peg_top)/2,
                    peg_height - peg_offset],
                    [(peg_bottom - peg_top)/2,
                    peg_height - peg_offset],
                ]);
            }
            polygon([
                [0, 0],
                [peg_bottom, 0],
                [peg_bottom - (peg_bottom - peg_top)/2,
                peg_height + peg_offset],
                [(peg_bottom - peg_top)/2,
                peg_height + peg_offset],
            ]);
        }
    }
}

union() {
    size = 15;
    max_x = 4;
    for (i=[0:max_x]) {
        for (j=[0:1]) {
            translate([j*32, i*28, 0]) {
                make_peg(8, 20, i + j*max_x + size, i + j*max_x + size + 2, 2, 2);
            }
        }
    }
}
