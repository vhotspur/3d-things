#!/bin/sh

generate() {
    echo "$( date '+[%Y-%m-%d %H:%M:%S] >>>> >>> >> >' )" "Generating bom-$2.stl (mode $1) ..." >&2
    openscad -o "bom-$2.stl" -D "to_print=$1" -D '$fn=100' battle-of-midway-2d.scad
}

generate 0 "fighter-generic"
generate 1 "bomber-generic"
generate 2 "fighter-american"
generate 3 "bomber-american"
generate 4 "fighter-japanese"
generate 5 "bomber-japanese"
generate 6 "activation-ring"

