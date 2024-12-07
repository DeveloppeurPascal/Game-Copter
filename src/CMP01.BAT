@echo off
set code=cptr01
olf_dat 0 gamecptr 0
lha a c:\olf_soft\lzh\%code% go01.bat copter01.dat olf_soft.dat
del olf_soft.dat
set code=
echo on
