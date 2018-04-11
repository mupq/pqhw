@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.3\\bin
call %xv_path%/xsim Test_NewHope_behav -key {Behavioral:sim_1:Functional:Test_NewHope} -tclbatch Test_NewHope.tcl -view C:/Users/Toder/Documents/HardwareProjects/NewHope/Test_RLWE_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
