# layout/wires.tcl: what your layout adds to Tiny Tapeout's empty frame.
#
# build.tcl runs this after it has loaded the frame (the pins from the DEF
# template and the power stripes from init.tcl), and before it writes gds/ and
# lef/. Two commands are available:
#
#   p LAYER X1 Y1 X2 Y2      paint a rectangle, corners in microns
#   place CELL X Y NAME      put a cell from layout/cells/ at (X, Y)
#
# Lab 01: a 9 um stub of metal 4 on each of the analog pins ua[0] and ua[1].
# info.yaml says analog_pins: 2, and precheck's analog pin check fails unless
# each of those two pins touches some metal. The stubs aren't connected to
# anything else; in Lab 03 you replace them with wires to an inverter.
#
# Each ua pin is 0.90 um wide and 1 um tall at the bottom edge of the tile. The
# x positions are the ones precheck checks (tech_data.py in tt-support-tools).

p metal4 151.81 1 152.71 10   ;# ua[0]
p metal4 132.49 1 133.39 10   ;# ua[1]
