@echo off
set code=cptr02
olf_dat 0 gamecptr 0
lha a c:\olf_soft\lzh\%code% go02.bat copter02.dat olf_soft.dat
del olf_soft.dat
set code=
echo on
