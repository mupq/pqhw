vlib work
vlib msim

vlib msim/xbip_dsp48_wrapper_v3_0_4
vlib msim/xbip_utils_v3_0_4
vlib msim/xbip_pipe_v3_0_0
vlib msim/xbip_dsp48_macro_v3_0_10
vlib msim/xil_defaultlib

vmap xbip_dsp48_wrapper_v3_0_4 msim/xbip_dsp48_wrapper_v3_0_4
vmap xbip_utils_v3_0_4 msim/xbip_utils_v3_0_4
vmap xbip_pipe_v3_0_0 msim/xbip_pipe_v3_0_0
vmap xbip_dsp48_macro_v3_0_10 msim/xbip_dsp48_macro_v3_0_10
vmap xil_defaultlib msim/xil_defaultlib

vcom -work xbip_dsp48_wrapper_v3_0_4 -64 -93 \
"./../../../ipstatic/xbip_dsp48_wrapper_v3_0_4/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_utils_v3_0_4 -64 -93 \
"./../../../ipstatic/xbip_utils_v3_0_4/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_0 -64 -93 \
"./../../../ipstatic/xbip_pipe_v3_0_0/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \
"./../../../ipstatic/xbip_pipe_v3_0_0/hdl/xbip_pipe_v3_0.vhd" \

vcom -work xbip_dsp48_macro_v3_0_10 -64 -93 \
"./../../../ipstatic/xbip_dsp48_macro_v3_0_10/hdl/xbip_dsp48_macro_v3_0_vh_rfs.vhd" \
"./../../../ipstatic/xbip_dsp48_macro_v3_0_10/hdl/xbip_dsp48_macro_v3_0.vhd" \

vcom -work xil_defaultlib -64 -93 \
"./../../../../NewHope.srcs/sources_1/ip/xbip_dsp48_macro_0/sim/xbip_dsp48_macro_0.vhd" \

quit -f

