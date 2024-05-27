#========================================================================== params
set BOARD          xc7a200tfbg484-1
set TOP_NAME       reg_wrapper
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
set NUM_OF_JOBS    64

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
#========================================================================== synt : end

#========================================================================== impl
launch_runs impl_1 -jobs $NUM_OF_JOBS -dir $SYNT_PATH
wait_on_run impl_1
#========================================================================== impl : end

#========================================================================== metrics collection
if {[file exists $RESULT_PATH] == 0} { 
  file mkdir $RESULT_PATH
}
set TIMING_REP     $RESULT_PATH/timing.txt
set UTILIZ_REP     $RESULT_PATH/utilization.txt

open_run impl_1

report_timing_summary -file $TIMING_REP
report_utilization    -file $UTILIZ_REP
#========================================================================== metrics collection : end

exit