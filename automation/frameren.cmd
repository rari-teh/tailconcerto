@echo off
set /a pointer=1
set /a new=0
:loop
ren %pointer%.bmp %new%.bmp
set /a pointer=%pointer%+1
set /a new=%new%+1
goto loop