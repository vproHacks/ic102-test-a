# layout/drc.tcl: `make drc`. Magic's full DRC deck on the committed GDS, the
# way precheck's first check reads it, but with the workbench's Magic and PDK.
# Writes layout/build/drc.txt.

set TOP $env(TOP)
file mkdir drc
cd drc
gds maskhints yes
gds read ../../../gds/$TOP.gds
load $TOP
select top cell
expand
drc euclidean on
drc style drc(full)
drc check
drc catchup

set total 0
set lines ""
foreach {why boxes} [drc listall why] {
    append lines "  [llength $boxes] x $why\n"
    incr total [llength $boxes]
}
set f [open ../drc.txt w]
puts $f "Magic DRC on gds/$TOP.gds: $total errors"
puts -nonewline $f $lines
close $f
quit -noprompt
