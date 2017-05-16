@echo off
C:

:loop
set /p "dir1="

cd %dir1%

dir %dir1%

goto loop

pause