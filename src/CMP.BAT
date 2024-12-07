@echo off
set code=gamecptr
mkmsg copter.txt copter.msg
lha a c:\olf_soft\lzh\%code% *.doc copter.exe copter.msg copter.pal copter.spr copter.fnt copter00.dat copter.prs
lha a c:\olf_soft\lzh\%code% c:\prg\others\divers\setdflt.exe c:\prg\others\divers\setstick.exe setup.cfg
set code=
echo on
