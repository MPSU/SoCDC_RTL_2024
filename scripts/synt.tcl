#========================================================================== params
set BOARD          xc7a200tfbg484-1
set TOP_NAME       icon_wrapper
set PROJ_NAME      proj_synt
#========================================================================== params : end

#========================================================================== paths
set TCL_PATH       [file dirname [file normalize [info script]]]
set SF_PATH        $TCL_PATH/synt_files
set TMP_PATH       $TCL_PATH/../tmp
set PROJ_PATH      $TMP_PATH/$PROJ_NAME
set SRC_PATH       $TCL_PATH/../rtl
set IF_PATH        $SRC_PATH/if
set SYNT_PATH      $TMP_PATH/synt
set RESULT_PATH    $TMP_PATH/result
#========================================================================== paths : end

#========================================================================== src files
set IF_FILES       [glob -directory $IF_PATH "*.*v"]
set SRC_FILES      [glob -directory $SRC_PATH "*.*v*"]
set WRAPPER        $SF_PATH/$TOP_NAME.sv
set CONSTRAINTS    $SF_PATH/constr.xdc
#========================================================================== src files : end

#========================================================================== tmp clear
if {[file exists $PROJ_PATH] == 1} { 
  file delete -force -- $PROJ_PATH
}
if {[file exists $SYNT_PATH] == 1} { 
  file delete -force -- $SYNT_PATH
}
file mkdir $PROJ_PATH
cd $PROJ_PATH
#========================================================================== tmp clear : end

#========================================================================== proj_build
create_project $PROJ_NAME $PROJ_PATH -part $BOARD
add_files $IF_FILES
add_files $SRC_FILES
add_files $WRAPPER
set_property top $TOP_NAME [current_fileset]
update_compile_order -fileset [current_fileset]
#========================================================================== proj_build : end

#========================================================================== synt : end
set NETLIST        $RESULT_PATH/netlist.v
set NUM_OF_JOBS    64

if {[file exists $RESULT_PATH] == 0} { 
  file mkdir $RESULT_PATH
}

# adding constraints
add_files $CONSTRAINTS

# out_of_context synt
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]

# full flatten hierarchy (for netlist)
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY full [get_runs synth_1]

set_msg_config -id "Synth 8-7129" -limit 500

# running synt
launch_runs synth_1 -jobs $NUM_OF_JOBS -dir $SYNT_PATH
wait_on_run synth_1

# creating netlist with library cells included
open_run synth_1

write_verilog -mode funcsim -include_xilinx_libs -force $NETLIST -rename_top liteic_icon_top
#========================================================================== synt : end

exit