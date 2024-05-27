#========================================================================== params
set BOARD          xc7a200tfbg484-1
set TOP_NAME       reg_wrapper
set PROJ_NAME      proj
#========================================================================== params : end

#========================================================================== paths
set TCL_PATH       [file dirname [file normalize [info script]]]
set SF_PATH        $TCL_PATH/synt_files
set TMP_PATH       $TCL_PATH/../tmp
set PROJ_PATH      $TMP_PATH/$PROJ_NAME
set SRC_PATH       $TCL_PATH/../rtl
set IF_PATH        $SRC_PATH/if
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
file mkdir $PROJ_PATH
cd $PROJ_PATH
#========================================================================== tmp clear : end

#========================================================================== proj_build
create_project $PROJ_NAME $PROJ_PATH -part $BOARD
add_files $IF_FILES
add_files $SRC_FILES
add_files $WRAPPER
add_files $CONSTRAINTS
set_property top $TOP_NAME [current_fileset]
update_compile_order -fileset [current_fileset]

# out_of_context synt
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]

# full hierarchy
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
#========================================================================== proj_build : end

#========================================================================== gui
start_gui
#========================================================================== gui : end