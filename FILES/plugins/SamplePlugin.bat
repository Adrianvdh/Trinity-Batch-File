REM Author: Adrian van den Houten
REM Date: 2014/01/09 - 02:37 AM
REM ************************************************************
REM Addons are allowed, under the terms of this addon contract:
REM Batch files, that should be used as Addons:
REM - Have to be be placed within the "Trinity.bat's" subfolder
REM named "plugins", and must have "@rem " as the first 4 bytes
REM followed by "TRINITY_ADDIN" followed by the name of the
REM function, version, author and release date.
REM Including your own license/declaimer with this addon is
REM allowed, in form of a COPYING file or the addon itself.
REM Permission to remove the contract stationery is allowed, but
REM please include the below:
REM ************************************************************

@rem TRINITY_ADDIN
REM Addon for "Trinity"
REM Addon name: 
REM Version: 
REM Author: 
REM Date: 

set ProductName=Sample
set version=1.0

call :callcuntion :samplefunction, mainmenu 5 n

:samplefunction
echo This is my sample function
pause
exit /b

rem End of addon