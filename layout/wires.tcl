# layout/wires.tcl: what your layout adds to Tiny Tapeout's empty frame.
#
# build.tcl runs this after it has loaded the frame (the pins from the DEF
# template and the power stripes from init.tcl), and before it writes gds/ and
# lef/. Three commands are available:
#
#   p LAYER X1 Y1 X2 Y2      paint a rectangle, corners in microns
#   place CELL X Y NAME      put a cell from layout/cells/ at (X, Y)
#   tieoff VGND_X            tie every digital output pin to the VGND stripe at VGND_X
#
# Lab 03 (reference solution): the inverter from AD104 Lab 03, its input A
# wired to ua[0], its output Y wired to ua[1], and its supplies to the two
# power stripes.
#
# The layers, from the bottom up, and the contact that joins each pair:
#   locali  -- mcon --  metal1  -- via1 --  metal2  -- via2 --  metal3  -- via3 --  metal4
# The cell's pins are on locali (A and Y) and metal1 (VPWR and VGND); the tile's
# pins and the power stripes are on metal4. In Magic's SKY130 technology a via
# is drawn as one rectangle that includes the metal around the cut, so each via
# rectangle below is a little bigger than the cut itself: at least 0.26 um
# across for via1, 0.28 for via2 and 0.32 for via3.

# ---------------------------------------------------------------- the cell
# 3.00 x 6.00 um. Relative to its lower-left corner: VGND is a metal1 rail along
# the bottom (y 0 to 0.40) and VPWR one along the top (y 5.60 to 6.00); A is a
# locali pad at x 1.24 to 1.61, y 2.34 to 2.71; Y is a locali strip at x 2.18
# to 2.55, y 1.45 to 4.17. Placed at (140, 10), so add 140 to every x and 10
# to every y.
place ic102_inv 140 10 inv0

# ------------------------------------------------------------------ supplies
# init.tcl draws a VGND stripe from x = 136 to 138 and a VDPWR stripe from
# x = 146 to 148 (Part 2 of the lab sets those). Each rail runs out sideways on
# metal1 and climbs to its stripe through a 1.2 um stack of via1, via2 and via3.
p metal1 136.4 10.0 140.0 10.4      ;# VGND rail, extended west
p metal1 136.4  9.6 137.6 10.8      ;# landing pad under the VGND stripe
p metal2 136.4  9.6 137.6 10.8
p metal3 136.4  9.6 137.6 10.8
p via1   136.7  9.9 137.3 10.5
p via2   136.7  9.9 137.3 10.5
p via3   136.7  9.9 137.3 10.5

p metal1 143.0 15.6 147.6 16.0      ;# VPWR rail, extended east
p metal1 146.4 15.2 147.6 16.4      ;# landing pad under the VDPWR stripe
p metal2 146.4 15.2 147.6 16.4
p metal3 146.4 15.2 147.6 16.4
p via1   146.7 15.5 147.3 16.1
p via2   146.7 15.5 147.3 16.1
p via3   146.7 15.5 147.3 16.1

# ------------------------------------------------------------- A to ua[0]
# Down at the cell: a contact from A's locali pad up to metal2, at the pad's
# centre (141.425, 12.525). The extra locali square repeats the cell's own pad
# in this cell, because Magic checks the minimum area of locali in each cell.
p locali 141.24 12.34 141.61 12.71
p mcon   141.34 12.44 141.51 12.61
p metal1 141.225 12.325 141.625 12.725
p via1   141.295 12.395 141.555 12.655
# East on metal2, under the VDPWR stripe, to ua[0] at x = 151.81 to 152.71.
p metal2 141.2 12.3 152.56 12.75
# Up to metal4 at ua[0]'s x, then down metal4 to the pin at the bottom edge.
p metal2 151.96 12.2 152.56 12.8
p metal3 151.96 12.2 152.56 12.8
p via2   152.10 12.36 152.42 12.68
p via3   152.08 12.34 152.44 12.70
p metal4 151.81 0 152.71 12.8

# ------------------------------------------------------------- Y to ua[1]
# The contact goes at (142.365, 13.485), on Y's strip and 0.6 um above A's
# metal2, so the two metal2 wires are 0.51 um apart.
p locali 142.18 13.30 142.55 13.67
p mcon   142.28 13.40 142.45 13.57
p metal1 142.165 13.285 142.565 13.685
p via1   142.235 13.355 142.495 13.615
# West on metal2, under the VGND stripe, to ua[1] at x = 132.49 to 133.39.
p metal2 132.64 13.26 142.6 13.71
# Up to metal4 at ua[1]'s x, then down metal4 to the pin.
p metal2 132.64 13.18 133.24 13.78
p metal3 132.64 13.18 133.24 13.78
p via2   132.78 13.32 133.10 13.64
p via3   132.76 13.30 133.12 13.66
p metal4 132.49 0 133.39 13.78

# ----------------------------------------------------------------- tie-offs
# Tiny Tapeout's analog specs say to connect unused uo_out, uio_out and uio_oe
# pins to ground. This ties all 24 to the VGND stripe at x = 136.
tieoff 136
