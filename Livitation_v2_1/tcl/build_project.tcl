########################################################################
#
#
#

set root_dir [ file normalize [file dirname [info script]]/../ ]
set device "xc6slx16ftg256-2"
set prj_name "SFTI_Livitation"
set language "VHDL"

# Create project
create_project $prj_name -force $root_dir/prj

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $prj_name]
set_property "part" $device $obj
set_property "target_language" "VHDL" $obj

########################################################################
# Sources
add_files -norecurse ../src/antenn_array_x16_control.vhd
add_files -norecurse ../src/clock_generator.vhd
add_files -norecurse ../src/fifo_non_simetric.vhd
add_files -norecurse ../src/Top.vhd
add_files -norecurse ../src/UART_RX.vhd
add_files -norecurse ../src/UART_TX.vhd
add_files -norecurse ../src/blk_mem_gen_v7_3_0/sin_mem.xci
add_files -norecurse ../src/blk_mem_gen_v7_3_1/get_param_mem.xci
add_files -norecurse ../src/fifo_generator_v9_3_0/uart_tx_fifo.xci
add_files -norecurse ../src/sinus_form_generator.vhd
########################################################################
# UCF
add_files -fileset [current_fileset -constrset] -norecurse ../ucf/constr.ucf
#set_property target_constrs_file ../ucf/constr.ucf [current_fileset -constrset]


#set_property SOURCE_SET sources_1 [get_filesets sim_1]
#add_files -fileset sim_1 -norecurse -scan_for_includes $root_dir/sim/const_package.vhd
#add_files -fileset sim_1 -norecurse -scan_for_includes $root_dir/sim/pci_arbt_module.vhd
#add_files -fileset sim_1 -norecurse -scan_for_includes $root_dir/sim/pci_host_module.vhd
#add_files -fileset sim_1 -norecurse -scan_for_includes $root_dir/sim/stream_pci_TB.vhd
#add_files -fileset sim_1 -norecurse -scan_for_includes $root_dir/sim/host_pc_module.vhd
#
#update_compile_order -fileset sim_1


