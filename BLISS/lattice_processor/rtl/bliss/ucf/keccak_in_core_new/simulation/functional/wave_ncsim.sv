

 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /keccak_in_core_new_tb/status
      waveform add -signals /keccak_in_core_new_tb/keccak_in_core_new_synth_inst/bmg_port/CLKA
      waveform add -signals /keccak_in_core_new_tb/keccak_in_core_new_synth_inst/bmg_port/ADDRA
      waveform add -signals /keccak_in_core_new_tb/keccak_in_core_new_synth_inst/bmg_port/DINA
      waveform add -signals /keccak_in_core_new_tb/keccak_in_core_new_synth_inst/bmg_port/WEA
      waveform add -signals /keccak_in_core_new_tb/keccak_in_core_new_synth_inst/bmg_port/DOUTA

console submit -using simulator -wait no "run"
