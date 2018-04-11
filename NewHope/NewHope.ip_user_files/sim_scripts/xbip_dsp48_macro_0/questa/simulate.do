onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib xbip_dsp48_macro_0_opt

do {wave.do}

view wave
view structure
view signals

do {xbip_dsp48_macro_0.udo}

run -all

quit -force
