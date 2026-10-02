# layout/build.tcl: the second half of `make`. You don't need to edit it; your
# changes go in layout/wires.tcl.
#
# `make` first runs layout/init.tcl, Tiny Tapeout's own script, which reads the
# 1x2 DEF template (the pins), draws the power stripes and saves the frame as
# layout/build/<top_module>.mag. Then it runs this file in layout/build/, which
# loads that frame, adds whatever wires.tcl draws, and writes the two files the
# gds workflow reads: gds/<top_module>.gds and lef/<top_module>.lef.

set TOP $env(TOP)
addpath ../cells
load $TOP

# p LAYER X1 Y1 X2 Y2: paint one rectangle on LAYER, corners in microns.
proc p {layer x1 y1 x2 y2} {
    box ${x1}um ${y1}um ${x2}um ${y2}um
    paint $layer
}

# place CELL X Y NAME: put an instance of CELL (from layout/cells/) with its
# lower-left corner at (X, Y) microns, and call the instance NAME.
proc place {cell x y name} {
    box ${x}um ${y}um ${x}um ${y}um
    getcell $cell
    identify $name
}

# The x centre of every digital output pin on the 1x2 template's top edge, from
# tt_analog_1x2.def: uo_out[0..7], uio_out[0..7], uio_oe[0..7].
set OUTPUT_PINS {
    uo_out  {94.30 91.54 88.78 86.02 83.26 80.50 77.74 74.98}
    uio_out {72.22 69.46 66.70 63.94 61.18 58.42 55.66 52.90}
    uio_oe  {50.14 47.38 44.62 41.86 39.10 36.34 33.58 30.82}
}

# tieoff VGND_X ?EXCEPT?: connect every digital output pin to ground, as Tiny
# Tapeout's analog specs ask for unused outputs. VGND_X is the left edge of a
# 2 um VGND stripe to the right of the pins. Each pin gets a short met4 stub and
# a via down to one met3 strap 1.5 um below the pins, and the strap ends in a
# via up to the stripe, which is extended to meet it. EXCEPT lists pins to
# leave alone, such as {uo_out[3]}, because something else drives them.
proc tieoff {vgnd_x {except {}}} {
    global OUTPUT_PINS
    foreach {bus xs} $OUTPUT_PINS {
        set i 0
        foreach xc $xs {
            if {[lsearch -exact $except "${bus}\[$i\]"] < 0} {
                p metal4 [expr {$xc - 0.15}] 222.5 [expr {$xc + 0.15}] 224.76
                p metal4 [expr {$xc - 0.25}] 222.5 [expr {$xc + 0.25}] 223.3
                p via3   [expr {$xc - 0.18}] 222.72 [expr {$xc + 0.18}] 223.08
            }
            incr i
        }
    }
    p metal3 30.42 222.5 [expr {$vgnd_x + 1.6}] 223.3
    p metal4 $vgnd_x 220.76 [expr {$vgnd_x + 2}] 223.3
    p via3 [expr {$vgnd_x + 0.6}] 222.5 [expr {$vgnd_x + 1.4}] 223.3
}

source ../wires.tcl

select top cell
save $TOP
gds write ../../gds/$TOP.gds
lef write ../../lef/$TOP.lef -hide -pinonly
puts "BUILD: done"
quit -noprompt
