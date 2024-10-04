
fs = 0.02;
name = "vhotspur";
font_size = 5.5;
zoom = 1.5;

function fn(a, b) = round(sqrt(pow(a[0]-b[0],2) + pow(a[1]-b[1], 2))/fs);

function b_pts(pts, n, idx) =
    len(pts)>2 ?
        b_pts([for(i=[0:len(pts)-2])pts[i]], n, idx) * n*idx
            + b_pts([for(i=[1:len(pts)-1])pts[i]], n, idx) * (1-n*idx)
        : pts[0] * n*idx
            + pts[1] * (1-n*idx);

function b_curv(pts) =
    let (fn=fn(pts[0], pts[len(pts)-1]))
    [for (i= [0:fn]) concat(b_pts(pts, 1/fn, i))];


$fn = 50;
    
scale(zoom) {
    linear_extrude(3) scale(1.5) union() {
        translate([32, 10]) circle(r=2);
        translate([28.5, 10]) circle(r=2);
        polygon(points = b_curv([
                [2, 0], [20, -5], [48, 0],
                [45, 10],
                [15, 5],
                [5, 5],
                [0, 2],
                [0, 0],
            ])
        );
        translate([-1.4, -2.3]) polygon(points = b_curv([
                [34, 5],
                [35, 12],
                [30, 15],
                [25, 5],
            ])
        );
        difference() {
            translate([5, 2]) polygon(points = b_curv([
                    [0, 0],
                    [-5, 21],
                    [12, 22],
                    [17, 22],
                    [20, 0],
                ])
            );
            translate([8, -0]) difference() {
                polygon(points = b_curv([
                        [0, 10],
                        [-2, 17],
                        [6, 17],
                        [10, 17],
                        [13, 10],
                    ])
                );
                polygon(points = b_curv([
                        [1, 8],
                        [-1, 15],
                        [5, 15],
                        [10, 15],
                        [12, 8],
                    ])
                );
            }
        }
    }
    translate([47, 15]) cylinder(r=1, h=4);
    translate([42, 15]) cylinder(r=1, h=4);
    translate([22, 5]) linear_extrude(4) text(name, size=font_size, halign="center", valign="center");
}
