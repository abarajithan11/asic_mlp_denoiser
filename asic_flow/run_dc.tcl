set top_module top
set rtlPath "../../src/"
exec mkdir -p log netlist

# Target library
set target_library /home/linux/ieng6/ee260bwi23/public/PDKdata/db/tcbn65gpluswc.db 
set link_library $target_library

#Compiler directives
set compile_effort "low"
set compile_no_new_cells_at_top_level false
set hdlin_auto_save_templates false
set wire_load_mode enclosed
set timing_use_enhanced_capacitance_modeling true
set verilogout_single_bit false
remove_design -all

define_design_lib WORK -path .template

# read RTL
analyze -format sverilog ../../src/luts.sv
analyze -format sverilog ../../src/matvec_mul.sv
analyze -format sverilog ../../src/mlp_serial.sv 

analyze -format sverilog ../../create_mlp_activations/create_mlp_activations.sv 
analyze -format sverilog ../../create_mlp_activations/addr_calc.sv 
analyze -format sverilog ../../create_mlp_activations/age_calc.sv 

analyze -format sverilog ../../src/top.sv 

# analyze -format verilog [glob ${rtlPath}*.v]
elaborate $top_module
current_design $top_module
check_design > log/${top_module}_check.rep

# Link Design
link

# Default SDC Constraints (can be an sdc file)

# set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {key[52]}]
read_sdc ../${top_module}.sdc

propagate_constraints
current_design $top_module

set_cost_priority {max_transition max_fanout max_delay max_capacitance}
set_fix_multiple_port_nets -all -buffer_constants
set_fix_hold [all_clocks]

set_driving_cell -lib_cell BUFFD8 -pin Z [all_inputs]
# set_load [get_attribute "$target_library/BUFFD8/A" fanout_load] [all_outputs]
foreach_in_collection p [all_outputs] {
	set_load 0.050 $p
}

#More compiler directives
set compile_effort   "high"
set_app_var ungroup_keep_original_design true
set_register_merging [get_designs $top_module] false
set compile_seqmap_propagate_constants false
set compile_seqmap_propagate_high_effort false
# More constraints and setup before compile
foreach_in_collection design [ get_designs "*" ] {
	current_design $design
	#feedthrough / outputs / constants
	set_fix_multiple_port_nets -all
}
current_design $top_module

# Compile
compile_ultra -no_autoungroup -timing_high_effort_script -exact_map

# Write Out Design - Hierarchical
current_design $top_module
change_names -rules verilog -hierarchy
write -format verilog -hier -output netlist/${top_module}.out.v

# Write Reports
report_area > log/${top_module}_area.rep
report_reference > log/${top_module}_area_reference.rep
report_power > log/${top_module}_power.rep
report_timing -path full -max_paths 100 -nets -transition_time -capacitance -significant_digits 3 -nosplit >  log/${top_module}_timing.rep


set unmapped_designs [get_designs -filter "is_unmapped == true" $top_module]
if {  [sizeof_collection $unmapped_designs] != 0 } {
	echo "****************************************************"
	echo "* ERROR!!!! Compile finished with unmapped logic.  *"
	echo "****************************************************"
}
