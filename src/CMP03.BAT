@echo off
set code=cptr03
olf_dat 0 gamecptr 0
lha a c:\olf_soft\lzh\%code% go03.bat copter03.dat olf_soft.dat
del olf_soft.dat
set code=
echo on
