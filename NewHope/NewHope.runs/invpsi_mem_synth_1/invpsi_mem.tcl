# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a35tcpg236-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.cache/wt [current_project]
set_property parent.project_path C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property vhdl_version vhdl_2k [current_fileset]
read_ip C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem.xci
set_property used_in_implementation false [get_files -all c:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem.dcp]
set_property is_locked true [get_files C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem.xci]

synth_design -top invpsi_mem -part xc7a35tcpg236-1 -mode out_of_context
rename_ref -prefix_all invpsi_mem_
write_checkpoint -noxdef invpsi_mem.dcp
catch { report_utilization -file invpsi_mem_utilization_synth.rpt -pb invpsi_mem_utilization_synth.pb }
if { [catch {
  file copy -force C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.runs/invpsi_mem_synth_1/invpsi_mem.dcp C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem.dcp
} _RESULT ] } { 
  error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
}
if { [catch {
  write_verilog -force -mode synth_stub C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem_stub.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}
if { [catch {
  write_vhdl -force -mode synth_stub C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem_stub.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}
if { [catch {
  write_verilog -force -mode funcsim C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem_sim_netlist.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}
if { [catch {
  write_vhdl -force -mode funcsim C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem_sim_netlist.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if {[file isdir C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.ip_user_files/ip/invpsi_mem]} {
  catch { 
    file copy -force C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem_stub.v C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.ip_user_files/ip/invpsi_mem
  }
}

if {[file isdir C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.ip_user_files/ip/invpsi_mem]} {
  catch { 
    file copy -force C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem_stub.vhdl C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.ip_user_files/ip/invpsi_mem
  }
}