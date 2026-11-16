# Makefile for an IC102-A project, copied into your repository by IC102-A Lab 01.
# Run every target from the top folder of your repository, in a workbench terminal.
#
#   make             build the layout: gds/<top_module>.gds and lef/<top_module>.lef
#   make docs        the docs workflow's check of info.yaml and docs/info.md
#   make precheck    Tiny Tapeout's precheck, with the runner's tool versions
#   make drc         Magic DRC of gds/ with the workbench's Magic, to compare
#   make lvs         LVS of gds/ against layout/lvs/reference.spice (Lab 03)
#   make view        open the layout in Magic on the desktop
#   make clean       delete layout/build/
#
# The checks come from the IC102-A course folder, which `mod add ic102-a` cloned.
# If yours is somewhere else, run for example: make precheck IC102=/path/to/ic102-a

SHELL    := /bin/bash
IC102    ?= /foss/designs/modules/ic102-a
TT_TOOLS := $(IC102)/labs/common/tt-tools
BUILD    := layout/build
export PDK := sky130A

# The layout is built and extracted with precheck's own Magic and PDK, the
# versions the course installs in $(TT_TOOLS)/.local (Lab 01, Part 1), so the
# GDS you commit comes from the Magic that precheck runs. The workbench's Magic
# and PDK are used only by `make drc`, to compare, and by `make view`, which
# needs a display.
PIN_MAGIC := $(firstword $(wildcard $(TT_TOOLS)/.local/magic-*/bin/magic))
PIN_PDK   := $(TT_TOOLS)/.local/pdk
WB_PDK    := /foss/pdks
RC         = $(1)/sky130A/libs.tech/magic/sky130A.magicrc

TOP      := $(shell python3 -c 'import yaml; print(yaml.safe_load(open("info.yaml"))["project"]["top_module"])' 2>/dev/null)
INIT_TOP := $(shell sed -n 's/^set TOP_LEVEL_CELL *\([^ ;]*\).*/\1/p' layout/init.tcl 2>/dev/null)

# Run precheck's Magic in batch mode inside $(BUILD): $(1) is the script and
# $(2) the log. Every target judges a Magic run by the files it wrote and not by
# its exit status, because a Magic that crashes can still have written them,
# and one that exits cleanly can still have failed to.
define magic_batch
	( cd $(BUILD) && ulimit -c 0 && env -u LD_LIBRARY_PATH PDK_ROOT=$(PIN_PDK) TOP=$(TOP) \
	    $(PIN_MAGIC) -dnull -noconsole -rcfile $(call RC,$(PIN_PDK)) $(1) < /dev/null > $(2) 2>&1 ) \
	    2>> $(BUILD)/$(2) || true
endef

# drc and lvs check the files you commit, gds/ and lef/, as precheck does, so
# they warn when a layout source is newer than the GDS.
STALE = $(shell for f in layout/*.tcl layout/cells/*; do [ -e "$$f" ] && [ "$$f" -nt gds/$(TOP).gds ] && echo "$$f"; done 2>/dev/null)

.PHONY: all layout check-top check-gds docs precheck drc lvs view clean help

all: layout

help:
	@sed -n '3,11p' Makefile

check-top:
	@[ -x "$(PIN_MAGIC)" ] && [ -f "$(call RC,$(PIN_PDK))" ] || { \
	  echo "precheck's Magic and PDK aren't installed in $(TT_TOOLS)/.local; run: make -C $(TT_TOOLS) install"; exit 1; }
	@[ -n "$(TOP)" ] || { echo "make: can't read project.top_module from info.yaml"; \
	  ! grep -n '^<<<<<<<\|^=======\|^>>>>>>>' info.yaml || echo "info.yaml still has conflict markers on the lines above"; exit 1; }
	@[ "$(INIT_TOP)" = "$(TOP)" ] || { \
	  echo "layout/init.tcl draws a cell called '$(INIT_TOP)', but top_module in info.yaml is '$(TOP)'."; \
	  echo "Set TOP_LEVEL_CELL in the settings block of layout/init.tcl to $(TOP)."; exit 1; }

layout: check-top
	@rm -rf $(BUILD)
	@mkdir -p $(BUILD) gds lef
	@cp layout/tt_analog_1x2.def $(BUILD)/
	@echo "magic: the kit's frame and power stripes (layout/init.tcl)"
	@$(call magic_batch,../init.tcl,init.log)
	@[ -f $(BUILD)/$(TOP).mag ] || { echo "init.tcl didn't save $(TOP).mag; read $(BUILD)/init.log"; \
	       grep -m3 '^Error' $(BUILD)/init.log | sed 's/^/  /'; exit 1; }
	@rm -f gds/$(TOP).gds lef/$(TOP).lef
	@echo "magic: your additions (layout/wires.tcl), then GDS and LEF"
	@$(call magic_batch,../build.tcl,build.log)
	@[ -s gds/$(TOP).gds ] && grep -q '^END LIBRARY' lef/$(TOP).lef 2>/dev/null \
	  || { echo "build.tcl didn't write gds/$(TOP).gds and lef/$(TOP).lef; read $(BUILD)/build.log"; \
	       grep -m3 '^Error' $(BUILD)/build.log | sed 's/^/  /'; exit 1; }
	@echo "wrote gds/$(TOP).gds and lef/$(TOP).lef"

check-gds: check-top
	@[ -f gds/$(TOP).gds ] || { echo "no gds/$(TOP).gds yet; run: make"; exit 1; }
	@mkdir -p $(BUILD)
	@[ -z "$(STALE)" ] || echo "warning: $(STALE) changed after gds/$(TOP).gds was written; run make to rebuild it"

docs:
	@[ -x $(TT_TOOLS)/.local/venv/bin/python ] || { echo "the course tools aren't installed; run: make -C $(TT_TOOLS) install"; exit 1; }
	@cd $(TT_TOOLS)/.local/tt-support-tools && env -u PYTHONPATH $(TT_TOOLS)/.local/venv/bin/python -c \
	  'import sys; from project_checks import check_project_docs; check_project_docs(sys.argv[1], "sky130A")' $(CURDIR)

precheck:
	@$(MAKE) --no-print-directory -C $(TT_TOOLS) precheck PROJECT=$(CURDIR)

drc: check-gds
	@echo "magic: DRC of gds/$(TOP).gds with the workbench's Magic $$(magic --version) and PDK"
	@rm -f $(BUILD)/drc.txt
	@( cd $(BUILD) && ulimit -c 0 && PDK_ROOT=$(WB_PDK) TOP=$(TOP) magic -dnull -noconsole \
	    -rcfile $(call RC,$(WB_PDK)) ../drc.tcl < /dev/null > drc.log 2>&1 ) 2>> $(BUILD)/drc.log || true
	@[ -f $(BUILD)/drc.txt ] || { echo "drc.tcl wrote no report; read $(BUILD)/drc.log"; exit 1; }
	@cat $(BUILD)/drc.txt

# The reference netlist is layout/lvs/reference.spice, or, in a repository that
# has layout/lvs/reference.py (the Lab 04 sandbox), whatever that script writes.
LVS_REF := $(if $(wildcard layout/lvs/reference.py),$(BUILD)/reference.spice,layout/lvs/reference.spice)

lvs: check-gds
	@[ -f layout/lvs/reference.py ] && python3 layout/lvs/reference.py $(TOP) > $(LVS_REF) || true
	@[ -f $(LVS_REF) ] || { echo "no layout/lvs/reference.spice yet: Lab 03 adds it"; exit 1; }
	@echo "magic: extract a netlist from gds/$(TOP).gds"
	@rm -f $(BUILD)/$(TOP).spice $(BUILD)/lvs.report
	@$(call magic_batch,../extract.tcl,extract.log)
	@[ -f $(BUILD)/$(TOP).spice ] || { echo "extract.tcl wrote no netlist; read $(BUILD)/extract.log"; exit 1; }
	@echo "netgen: the extracted netlist against $(LVS_REF)"
	@netgen -batch lvs "$(BUILD)/$(TOP).spice $(TOP)" "$(LVS_REF) $(TOP)" \
	  $(PIN_PDK)/sky130A/libs.tech/netgen/sky130A_setup.tcl $(BUILD)/lvs.report > $(BUILD)/netgen.log 2>&1 || true
	@[ -f $(BUILD)/lvs.report ] || { echo "netgen wrote no report; read $(BUILD)/netgen.log"; exit 1; }
	@grep '^Final result' $(BUILD)/lvs.report | sed 's/^/  /'
	@grep -E 'no pin|no matching|Mismatch' $(BUILD)/lvs.report | sort -u | head -40 | sed 's/^/  /' || true
	@echo "full report: $(BUILD)/lvs.report"

view:
	@[ -f $(BUILD)/$(TOP).mag ] || { echo "nothing to show yet; run: make"; exit 1; }
	@cd $(BUILD) && PDK_ROOT=$(WB_PDK) magic -d X11 -rcfile $(call RC,$(WB_PDK)) $(TOP) &

clean:
	rm -rf $(BUILD)
