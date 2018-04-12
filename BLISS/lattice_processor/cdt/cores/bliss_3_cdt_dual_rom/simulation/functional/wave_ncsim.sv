

 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /bliss_3_cdt_dual_rom_tb/status
      waveform add -signals /bliss_3_cdt_dual_rom_tb/bliss_3_cdt_dual_rom_synth_inst/bmg_port/CLKA
      waveform add -signals /bliss_3_cdt_dual_rom_tb/bliss_3_cdt_dual_rom_synth_inst/bmg_port/ADDRA
      waveform add -signals /bliss_3_cdt_dual_rom_tb/bliss_3_cdt_dual_rom_synth_inst/bmg_port/DOUTA

console submit -using simulator -wait no "run"
