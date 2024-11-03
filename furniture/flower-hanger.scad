
include <BOSL2/std.scad>

$fn = 30;

module hanger() {
    /*cylinder(h=15, r=2);
    up(15) {
        resize([12, 12, 8]) {
            sphere(6);
        }
    }*/
    
    //up(18) zflip() onion(r=8, ang=25, cap_h=18);
    up(34) zflip() resize([16, 16, 34])
    {
        onion(r=20, ang=2, cap_h=220);
    }
}

module petal() {
    left(25) {
        left(6) {
            hanger();
        }
        minkowski() {
            linear_extrude(2) {
                egg(length=42, r1=15, r2=6, R=60);
            }
            sphere(1);
        }
    }
}


zrot_copies(n=5) {
    petal();
}

minkowski() {
    linear_extrude(3) {
        circle(15);
        //circle(9);
    }
    sphere(1);
}
//hanger();

