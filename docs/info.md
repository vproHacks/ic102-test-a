<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

A single CMOS inverter: ua[0] is its input and ua[1] its output.

## How to test

Drive ua[0] from 0 V to 1.8 V and watch ua[1] fall from 1.8 V to 0 V.

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any

## Pins

ua[0] is the input and ua[1] the output. Every digital output is tied to ground.

A 1 kHz square wave on ua[0] is enough to see the inversion on an oscilloscope.

A second inverter, to make a buffer, is placed but not wired yet.

The pins again: ua[0] is in, ua[1] is out.
