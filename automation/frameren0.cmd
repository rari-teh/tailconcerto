@echo off
set /a pointer=1
set /a new=0
:loop
ren 0%pointer%.bmp 0%new%.bmp
set /a pointer=%pointer%+1
set /a new=%new%+1
goto loop