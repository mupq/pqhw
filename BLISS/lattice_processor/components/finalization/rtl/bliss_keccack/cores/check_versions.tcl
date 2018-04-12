##
## Core Generator Run Script, generator for Project Navigator checkversion command
##

proc findRtfPath { relativePath } {
   set xilenv ""
   if { [info exists ::env(XILINX) ] } {
      if { [info exists ::env(MYXILINX)] } {
         set xilenv [join [list $::env(MYXILINX) $::env(XILINX)] $::xilinx::path_sep ]
      } else {
         set xilenv $::env(XILINX)
      }
   }
   foreach path [ split $xilenv $::xilinx::path_sep ] {
      set fullPath [ file join $path $relativePath ]
      if { [ file exists $fullPath ] } {
         return $fullPath
      }
   }
   return ""
}

source [ findRtfPath "data/projnav/scripts/dpm_cgUtils.tcl" ]

set result [ run_cg_vcheck {C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/rtl/fft/ipcore/mul_17x17.xco C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/rtl/fft/ipcore/mul_34_34.xco C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/rtl/fft/ipcore/mul_64x64.xco C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/rtl/bliss_keccack/cores/hash_buffer_ram.xco C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/rtl/bliss_keccack/cores/keccak_in_core.xco C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/rtl/bliss_keccack/cores/message_RAM.xco C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/rtl/sparse_mul/cores/s1_ram_core.xco C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/rtl/sparse_mul/cores/s2_ram_core.xco C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/rtl/finalization/cores/norm_mac_core.xco C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/rtl/bliss_keccack/cores/c_ram.xco} xc6slx25-3csg324 ]

if { $result == 0 } {
   puts "Core Generator checkversion command completed successfully."
} elseif { $result == 1 } {
   puts "Core Generator checkversion command failed."
} elseif { $result == 3 || $result == 4 } {
   # convert 'version check' result to real return range, bypassing any messages.
   set result [ expr $result - 3 ]
} else {
   puts "Core Generator checkversion cancelled."
}
exit $result
