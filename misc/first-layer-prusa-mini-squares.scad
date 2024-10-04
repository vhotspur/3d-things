x_size = 172;
y_size = 172;
x_count = 3;
y_count = 3;
size = 10;
connection = 3;
shift = size / 4;
height = 0.2;

function get_base_offset(total_width, object_width, object_count) =
    (total_width - object_width) / (object_count - 1);

linear_extrude(height) {
    let (
            x_offset = get_base_offset(x_size, size, x_count),
            y_offset = get_base_offset(y_size, size, y_count)
    ) for (x = [0:x_count-1]) {
        for (y = [0:y_count-1]) {
            translate([x * x_offset, y * y_offset]) square([size, size]);
        }
    }
    let (x_offset = get_base_offset(x_size - 2*shift, connection, x_count)) for (x = [0:x_count-1]) {
        translate([shift + x*x_offset, 0]) square([connection, y_size]);
    }
    let (y_offset = get_base_offset(y_size - 2*shift, connection, y_count)) for (y = [0:y_count-1]) {
        translate([0, shift + y*y_offset, 0]) square([x_size, connection]);
    }
    translate([1.2*size, y_size / 2]) text("L", size = size*1.2, halign="left", valign="center");
    translate([x_size - 1.2*size, y_size / 2]) text("R", size = size*1.2, halign="right", valign="center");
}
