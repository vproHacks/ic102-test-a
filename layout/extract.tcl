# layout/extract.tcl: the first half of `make lvs`. Reads the committed GDS and
# writes the circuit Magic finds in it to layout/build/<top_module>.spice.
#
# `ext2spice short resistor` matters here: the tied-off output pins are all on
# the VGND net, and without it Magic would keep only one name for that net and
# drop the 24 pins. With it, each tied pin stays a port, joined to VGND by a
# 0-ohm resistor, and layout/lvs/reference.spice says the same thing.

set TOP $env(TOP)
file mkdir lvs
cd lvs
gds read ../../../gds/$TOP.gds
load $TOP
select top cell
extract do local
extract all
ext2spice lvs
ext2spice short resistor
ext2spice -o ../$TOP.spice
quit -noprompt
