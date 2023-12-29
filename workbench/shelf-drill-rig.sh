#!/bin/sh

generate() {
    echo "$( date '+[%Y-%m-%d %H:%M:%S] >>>> >>> >> >' )" "Generating shelf-rig-$2.stl (mode $1) ..." >&2
    openscad -o "shelf-rig-$2.stl" -D "to_print=$1" -D '$fn=100' shelf-drill-rig.scad
}

generate 0 "main"
generate 1 "continuation-pin"
generate 2 "start-pin"

