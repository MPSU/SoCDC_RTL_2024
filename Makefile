SCRIPT_DIR := ./scripts
TMP_DIR := ./tmp

PROJ_SCRIPT := $(SCRIPT_DIR)/proj.tcl
SYNT_SCRIPT := $(SCRIPT_DIR)/synt.tcl
METR_SCRIPT := $(SCRIPT_DIR)/metr.tcl
PY_SCRIPT   := $(SCRIPT_DIR)/metr_collection.py

all:	proj

proj:
	vivado -mode tcl -source $(PROJ_SCRIPT) -nolog -nojournal

synt:
	vivado -mode tcl -source $(SYNT_SCRIPT) -nolog -nojournal

metr:
	vivado -mode tcl -source $(METR_SCRIPT) -nolog -nojournal
	python3 $(PY_SCRIPT)

clean:
	rm -rf ./tmp