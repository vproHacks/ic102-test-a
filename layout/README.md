# layout/

The layout in `gds/` and `lef/` is built from the files in this folder. Run
`make` from the top of the repository to rebuild it, in a terminal in the
IC102-A workbench, and `make help` for the other targets.

| File | What it is | Who edits it |
|---|---|---|
| `init.tcl` | Tiny Tapeout's `magic_init_project.tcl`: reads the DEF, draws the power stripes, saves the frame | you, in its settings block only |
| `tt_analog_1x2.def` | Tiny Tapeout's 1x2 analog template: the tile's size and every pin | nobody |
| `UPSTREAM.md` | where those two files came from | nobody |
| `wires.tcl` | everything the layout adds to the frame | you |
| `cells/` | cells that `wires.tcl` places (from Lab 03) | you, if you change a cell |
| `lvs/reference.spice` | the circuit the layout should contain, for `make lvs` (from Lab 03) | you |
| `build.tcl`, `drc.tcl`, `extract.tcl` | the scripts behind `make`, `make drc` and `make lvs` | nobody |
| `build/` | scratch output, ignored by git | nobody |
