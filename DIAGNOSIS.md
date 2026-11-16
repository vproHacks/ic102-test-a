# Lab 02 diagnosis

One entry per breakage. Fill in the prediction before you push, and the rest from the run on
GitHub. Commit this file with the fix, so the entry and the commit that answers it go together.

## Breakage 1

- Predicted: the job that fails first, and why: docs, because its info.yaml check wants a pinout, and it is one short job; precheck's analog pin check should fail later too.
- Run: https://github.com/vproHacks/ic102-test-a/actions/runs/43830783046 (docs) and https://github.com/vproHacks/ic102-test-a/actions/runs/43830783971 (gds)
- Job and step that failed: docs, step "Build docs" (inner step "Check info.yaml and docs/info.md"); later precheck, step "Run Tiny Tapeout Precheck", Analog pin check
- First error line, copied from the log: `- Please fill in the 'pinout' section`
- Cause, in one sentence: every pinout description was emptied, so docs finds no pinout and precheck finds metal on ua[0] with no description.
- Fix, and the commit that made the run green: put the two ua descriptions back (this commit)

## Breakage 2

- Predicted: precheck, because docs reads only info.yaml and docs/info.md, which didn't change; the analog pin check should see metal on ua[2] with analog_pins set to 2.
- Run: https://github.com/vproHacks/ic102-test-a/actions/runs/43831964719
- Job and step that failed: precheck, step "Run Tiny Tapeout Precheck", Analog pin check
- First error line: `| Analog pin check | ❌ Fail: Analog pin `ua[2]` is connected to some metal but `analog_pins` is set to 2 in `info.yaml`. ...`
- Cause: a stub of metal 4 on ua[2], a pin info.yaml doesn't claim.
- Fix, and the green commit: removed the stub and rebuilt (this commit)

## Breakage 3

- Predicted: gds goes green (it copies whatever file top_module names, and the renamed one is there), then precheck fails, because the cell inside the GDS still has the old name.
- Run: https://github.com/vproHacks/ic102-test-a/actions/runs/43832924021
- Job and step that failed: precheck, step "Run Tiny Tapeout Precheck": KLayout Checks, Pin check, urpm/nwell check
- First error line: `ERROR: Pin clk not found in .../tt_submission/tt_um_vprohacks_ic102_v2.lef` (after the Nix `error:` block every precheck log has)
- Cause: top_module and the file names say tt_um_vprohacks_ic102_v2, but the cell inside the GDS and the LEF's macro are still tt_um_vprohacks_ic102.
- Fix, and the green commit: undid the rename (this commit)

## Breakage 4

- Predicted: precheck, but not in a DRC deck: a clean square on metal 5 is legal SKY130, so I expect a layer check of Tiny Tapeout's to object.
- Run: https://github.com/vproHacks/ic102-test-a/actions/runs/43833875459
- Job and step that failed: precheck, step "Run Tiny Tapeout Precheck", KLayout Checks
- First error line: `| KLayout Checks | ❌ Fail: Forbidden layer met5.drawing found in /home/runner/work/ic102-test-a/ic102-test-a/tt_submission/tt_um_vprohacks_ic102.gds |`
- Cause: a square on metal 5, which Tiny Tapeout's analog rules forbid in the tile even though it passes DRC.
- Fix, and the green commit: removed the square and rebuilt (this commit)

## Breakage 5

- Predicted: precheck; with uses_vapwr true it should expect a VAPWR pin, so the power pin check, and maybe the pin check against a different template.
- Run:
- Job and step that failed:
- First error line:
- Cause:
- Fix, and the green commit:

## A mistake no workflow catches

One value in your repository that would be wrong, and that every workflow would still pass:
