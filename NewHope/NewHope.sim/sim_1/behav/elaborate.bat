@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.3\\bin
call %xv_path%/xelab  -wto 9a34579609f345ce927ce13932a2420b -m64 --debug typical --relax --mt 2 -L blk_mem_gen_v8_3_0 -L xil_defaultlib -L xbip_dsp48_wrapper_v3_0_4 -L xbip_utils_v3_0_4 -L xbip_pipe_v3_0_0 -L xbip_dsp48_macro_v3_0_10 -L secureip --snapshot Test_NewHope_behav xil_defaultlib.Test_NewHope -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
