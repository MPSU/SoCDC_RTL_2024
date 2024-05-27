SHELL := bash

#---------------------------------------------------------
# Makefile for AXI4 CRC DV
#---------------------------------------------------------

# Seed
SEED = $$RANDOM

# Output directory
OUT = ./out

# Netlist simulation switch
NETLIST = 0

# Run options
RUN_OPTS =

# GUI or console switch
ifeq ($(GUI),1)
	RUN_OPTS += -gui
else
	RUN_OPTS += -c
endif

# Verbosity
VERBOSITY = UVM_LOW

# Test
TEST = axi4_liteic_1k_test

# Transactions logging
ifeq ($(LOGGING),1)
	RUN_OPTS += +en_logging=1
endif

# Debugging
ifeq ($(DEBUG),1)
	RUN_OPTS += -voptargs="+acc"
else
	RUN_OPTS += -voptargs="+acc=npr+tb_liteic_top"
endif

# TB Sources
TB_SRCS = $(shell find ../uvm ../tb -name "*.*v")

# VHDL Sources
RTL_VHDL_PATH = rtl_vhdl.f
RTL_VHDL_SRCS = $(shell find ../../rtl -name "*.vhd")

# Verilog Sources
ifeq ($(NETLIST),1)
	RTL_SRCS = $(shell find ../../tmp/result -name "*.v")
	RTL_PATH = rtl_netlist.f
	TB_PATH  = tb_netlist.f
else
	RTL_SRCS  = $(shell find ../../rtl -name "*.sv")
	RTL_SRCS += $(shell find ../../rtl/if -name "*.sv")
	RTL_PATH = rtl.f
	TB_PATH  = tb.f
endif

.PHONY: run clean open_wave

# Run simulation
run: $(OUT)/vip_compile.stamp $(OUT)/rtl_compile.stamp $(OUT)/tb_compile.stamp | $(OUT)
	@echo -n "Running (log file at $(OUT)/rtl_run.log)... "
	@vsim  $(RUN_OPTS) tb_liteic_top glbl -sv_seed $(SEED) \
		-mvchome $$QUESTA_MVC_HOME -do questa.tcl +UVM_TESTNAME=$(TEST) \
			+UVM_VERBOSITY=$(VERBOSITY) +en_stats=1 -l $(OUT)/rtl_run.log \
			-wlf $(OUT)/rtl_wave.wlf +log_file_name=$(OUT)/hack_2024_rtl_stats.txt \
				> $(OUT)/rtl_run.log 
	@rm -rf transcript
	@echo "Done"

# Open last simulation waveform
open_wave:
	@echo -n "Opening $(OUT)/rtl_wave.wlf... "
	@vsim -view $(OUT)/rtl_wave.wlf -l $(OUT)/rtl_wave.log
	@echo "Done"

# Clean output directory
clean:
	rm -rf $(OUT) work

# TB compilation
$(OUT)/tb_compile.stamp: $(TB_SRCS) $(OUT)/NETLIST.$(NETLIST) | $(OUT)
	@echo -n "Compiling TB (log file at $(OUT)/tb_compile.log)... "
	@vlog -64 -sv -f $(TB_PATH) -timescale "1 ns / 1 ps" > $(OUT)/tb_compile.log
	@echo "Done"
	@touch $@

# RTL compilation
$(OUT)/rtl_compile.stamp: $(RTL_SRCS) $(RTL_VHDL_SRCS) \
	$(OUT)/NETLIST.$(NETLIST) $(RTL_PATH) $(RTL_VHDL_PATH) | $(OUT)
	@echo -n "Compiling RTL (log file at $(OUT)/rtl_compile.log)... "
	@vlog -64 -sv -f $(RTL_PATH) +nospecify -timescale "1 ns / 1 ps" > $(OUT)/rtl_compile.log
ifneq ($(RTL_VHDL_SRCS),)
	@vcom -64 -f $(RTL_VHDL_PATH) >> $(OUT)/rtl_compile.log
endif
	@echo "Done"
	@touch $@

# AXI4 VIP compilation
$(OUT)/vip_compile.stamp: | $(OUT)
	@echo -n "Compiling AXI4 VIP (log file at $(OUT)/vip_compile.log)... "
	@vlog -64 -sv -f vip.f -timescale "1 ns / 1 ps" > $(OUT)/vip_compile.log
	@echo "Done"
	@touch $@

$(OUT):
	@mkdir -p $@

$(OUT)/NETLIST.$(NETLIST):
	@rm -f $(OUT)/NETLIST.*
	@touch $@
