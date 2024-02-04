#!/bin/sh

msg() {
    echo "$( date '+[%Y-%m-%d %H:%M:%S] >>>> >>> >> >' )" "$@" >&2
}

generate() {
    msg "Generating bom-v1-$2.stl (mode $1) ..." >&2
    openscad -o "bom-v1-$2.stl" -D "to_print=$1" -D '$fn=100' battle-of-midway-2d.scad
}

start_time="$( date '+%s' )"

generate 0 "fighter-generic"
generate 1 "bomber-generic"
generate 2 "fighter-american"
generate 3 "bomber-american"
generate 4 "fighter-japanese"
generate 5 "bomber-japanese"
generate 6 "activation-ring"

end_time="$( date '+%s' )"
msg "Completed in" "$(( end_time - start_time ))" "seconds."
