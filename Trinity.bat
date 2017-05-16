@echo off
REM TRINITY_OFFICIAL_BATCH_FILE
REM Author: Adrian van den Houten
REM Date: 2015/04/28 - 05:36 PM
REM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
REM
REM Please read the GNU general public license agreement v3 before
REM viewing this scripts code:
REM
REM Trinity - The 3-in-1 file manager
REM Copyright (C) 2013-2015 Adrian van den Houten
REM
REM This program is free software: you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.
REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with this program.  If not, see http://www.gnu.org/licenses/
REM
REM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
REM
REM "Most" functions are developed @ http://www.dostips.com/
REM Disclaimer:
REM Plugins are allowed under open source and freeware use.
REM I am not responsible for any damage or loss of data.
REM It is strictly forbidden to sell this program without
REM permission of the author!
REM Removing or modification any of the licensing/disclaimers
REM is strictly forbidden.
REM
REM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
REM *Yes = 0; No = 1*
REM Write log to file
set log_mode=0
REM 
set check_update=1
REM 
set process_bar=1
REM 
set calc_duration=0
REM Use PowerShell (0) to generate a file dialogue or use command line user input (1) dialogue:
set "file_dialog=0"
REM Use alternative choice command function instead of choice.exe:
set "choice_func=1"
REM 
set ping_requests=2
REM Show ping output in new CLI form (1) or within current window (0)
set ping_output=0
REM 
set program_height=42
REM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
setlocal disableDelayedExpansion
set color=b
set version=3.1.0
set webhost=www.google.com

::Define options
set "options= /hosts: /imhosts: /networks: /admin: /p:"" /C: /n:"" /r:"" /a: /ex:"" /im:"" /f:"" /c: /s: /t:0 /?: "
::Set default option values
for %%O in (%options%) do for /f "tokens=1,* delims=:" %%A in ("%%O") do set "%%A=%%~B"

::Get options
:getoptions
if not "%~1"=="" (
  if "%~1"=="launch" ( shift /1&shift /3&goto %2 )
  setlocal enableDelayedExpansion
  set "test=!options:* %~1:=! "
  
  if "!test!"=="!options! " (
      >&2 echo Error: Invalid option %~1
      exit /b 1
  ) else if "!test:~0,1!"==" " (
      endlocal
      set "%~1=1"
  ) else (
      endlocal
      set "%~1=%~2"
      shift /1
  )
  shift /1
  goto :getoptions
)

if defined /? (
  title Command Prompt
  color 07
  goto parameter
)

REM Resize CLI Form
mode 52,13
REM Check Administrator Privileges
reg query "HKU\S-1-5-19" >nul 2>&1 && (
  goto InitiateDefaults
) || (
  echo Administrator Privileges Required^^!
  ping localhost -n 4 >nul
  exit
) 
:InitiateDefaults
REM Set CLI text colour
color %color%
REM Set CLI title text
call :title

REM Start program loading timer
call :GetInternational
call :GetSecs "%date%" "%time%" startTime1

REM Set default variables values
cls& echo Loading Default Values...

set _direct_mode=Blank Page
set _direct_state=uilocalhost
set _IP_address=127.0.0.1
set _ui_localhost_flag=false
set _load_Duration_UI=false
set _OS=Unknown
set _CPU=Unknown
set _productID=Unknown
set _editionID=Unknown

set _count=10
set _Errortime=5

REM Set allocation variablesREM Get name %~n0%~x0
set "_defaultKey=HKLM\Software\Trinity"
set "_defaultDir=%AppData%\Trinity"
set "_startDir=%~d0%~p0"
set "_logfileDir=%_startDir%Trinity Log.txt"

set "_hosts=%windir%\system32\drivers\etc\hosts"
set "_networks=%windir%\system32\drivers\etc\networks"
set "_im_hosts=%windir%\system32\drivers\etc\im_hosts"
set "_slmgr=%windir%\system32\_slmgr.vbs"

set "passfile=%tempdir%\pass.bat"
set "countfile=%tempdir%\count.bat"

cls& echo Validating Switches...

REM Start new thread to check "log_mode" value is valid, if not default loaded
start /b "" "%~f0" launch checkLogModeSwitch

  REM Try write to log file, if "ex" returns successful, delete existing log file and write header
  call :writeLogFile "test" ex

  if %ex%==0 (
    REM Delete existing log file
    if exist "%_logfileDir%" del "%_logfileDir%"
  )
  
REM Write header to log file
call :writeLogFile "Trinity version %version% started^!" ex
	
  REM  Start new thread to check "process_bar" value is valid, if not default loaded
  start /b "" "%~f0" launch checkProcBarSwitch
  
  REM  Start new thread to check "calc_duration" value is valid, if not default loaded
  start /b "" "%~f0" launch checkcalcDurationSwitch
  
  REM Start new thread to check "check_update" value is valid, if not default loaded
  start /b "" "%~f0" launch checkAutoUpdateSwitch
 
  REM  Start new thread to check "ping_requests" value is valid, if not default loaded
  start /b "" "%~f0" launch checkPingRequestsSwitch
  
  REM  Start new thread to check "ping_output" value is valid, if not default loaded
  start /b "" "%~f0" launch checkPingOutputSwitch
  
  REM  Start new thread to check "program_height" value is valid, if not default loaded
  start /b "" "%~f0" launch checkHeightSwitch

cls& echo Checking registry...
  if %process_bar%==0 call :procbar "1" ex

  call :writeLogFile "Checking registry..." ex

REM Checks if (global) default registry key exists, if not creates a key
  call :reqQuery "%_defaultKey%" ex
    if %ex%==1 (
      call :regInsert "%_defaultKey%" ex
    )

cls &echo Checking default directory...
  if %process_bar%==0 call :procbar "1" ex

  call :writeLogFile "Checking default directory..." ex

  REM Checks if (global) default directory exists, if not creates a default directory
  if not exist "%_defaultDir%" md "%_defaultDir%"
  

REM Check system version in a new thread
cls &echo Loading System Version...
  if %process_bar%==0 call :procbar "1" ex

  call :writeLogFile "Loading System Version.." ex

  start /b "" "%~f0" launch sysVerion REM CurrentVersion CurrentBuild OS cpuArch
  
  
REM Disclaimer CHECK
  
  
REM Password Check

call :checkPassModeReg
call :checkPassCountReg





if not exist "%passfile%" set passwordmode=Disabled

if "%enclode%"=="1" echo set count=%count%>"%countfile%"

if exist "%passfile%" call "%passfile%"
if exist "%countfile%" call "%countfile%"








set "enclode=reset encode"

call :getEPID EPID
if "%EPID%"=="extended" set EPID=Unknown
	
	
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] []>>"%logdir%"
call :writeLogFile "Running OS: %_OS% %CPU%" ex
call :writeLogFile "Application path: %StartDirApp%" ex



set Encrypt2=%EPID%
call :EncryptKeysV1

call :EncryptFunction

call :DecryptPassword

call :Program_Blocker




call :GetSecs "%date%" "%time%" endTime1


if "%passwordmode%"=="Enabled" goto securitycheck
if "%passwordmode%"=="Disabled" goto checkhostsfile

:securitycheck
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Security check menu status: Loaded menu]>>"%logdir%"
set loadDurationUI=true
if "%count%"=="0" (
cls
echo Security issue!
ping localhost -n 2 >nul
set count=3
goto register )
cls
mode 52,13
echo\
call :header 17
if "%count%" LEQ "10" (echo                   Retries left: %count%
) else (echo                    Retries left: %count% )
echo\
echo Enter password:
set "passcheck="
if "%passcharmapmode%"=="Enabled" (
set "startpassword=true"
call :replacepassChar )
if "%passcharmapmode%"=="Disabled" call :passCharnormal
:endhighend1
cls
if "%passcheck%"=="" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Security check status: User entry is blank...]>>"%logdir%"
goto securitycheck )
if "%passcheck%"=="%comp%" (
echo Key: "%passwordvar%"
ping localhost -n 2 >nul
goto securitycheck )
set /a count=%count%-1
if "%passcheck%"=="%enclode%" (
set enclode=1
cls
goto ADMIN )
if "%passencryptmap%"=="Enabled" (
if "%passcheck%"=="%DecryptOut%" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Security check status: Entry correct^^!]>>"%logdir%"
set "startpassword=false"
goto checkhostsfile ) )
if "%passcheck%"=="%passwordvar%" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Security check status: Entry correct^^!]>>"%logdir%"
set "startpassword=false"
goto checkhostsfile 
) else (
echo set "count=%count%">"%countfile%"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Security check status User input: %passcheck%]>>"%logdir%"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Security check status: Entry incorrect^^!]>>"%logdir%"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Security check status retries left: %count%]>>"%logdir%"
goto securitycheck )
exit /b
:passCharnormal
set /p passcheck=
exit /b

:register
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Security check register menu status: Loaded menu]>>"%logdir%"
set "productIDinput="
set loadDurationUI=true
mode 52,13
echo -Register
call :header 17
echo                   Retries left: %count%
echo\
echo Enter security key:
set /p productIDinput=
if "%productIDinput%"=="" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Security check register status: User entry is blank...]>>"%logdir%"
goto register )
set /a count=%count%-1
if "%productIDinput%"=="%EncryptOut%" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Security check register status: Entry correct^^!]>>"%logdir%"
echo set "count=10">"%countfile%"
goto scanhhostfile 
) else (
if "%count%"=="0" (
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Security check register status: Shutdown pc in t-%Errortime% seconds]>>"%logdir%"
shutdown /s /f /t %Errortime% /c "Your product ID retry entries have expired. Bye^^!"
cls
echo Security issue^^!
ping localhost -n 2 >nul
goto exit ) )
goto register




:checkhostsfile
call :GetInternational
call :GetSecs "%date%" "%time%" startTime2

cls &echo Checking hosts file...
  if %process_bar%==0 call :procbar "1" ex
  
  call :writeLogFile "Checking hosts file..." ex

  start /b "" "%~f0" launch scanhostsfile true true true
  
  call :GetSecs "%date%" "%time%" endTime2
  
:checkimhostsfile
call :GetInternational
call :GetSecs "%date%" "%time%" startTime2

cls &echo Checking hosts file...
  if %process_bar%==0 call :procbar "1" ex
  
  call :writeLogFile "Checking hosts file..." ex

  start /b "" "%~f0" launch scanhostsfile true true true
  
  call :GetSecs "%date%" "%time%" endTime2
  
:checknetworksfile
call :GetInternational
call :GetSecs "%date%" "%time%" startTime2

cls &echo Checking hosts file...
  if %process_bar%==0 call :procbar "1" ex
  
  call :writeLogFile "Checking hosts file..." ex

  start /b "" "%~f0" launch scanhostsfile true true true
  
  call :GetSecs "%date%" "%time%" endTime2


:modife_hostsfilestart
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [_hosts file check status: User requests modify file...]>>"%logdir%"
echo\
attrib -r "%_hosts%"
if exist "%_hosts%" del /F /Q "%_hosts%"
echo(>>"%_hosts%"
attrib +r "%_hosts%"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [_hosts file check status: Now modified]>>"%logdir%"
set "_hostsfilecheckflag=Now modified"
echo Done - Modifying File^^!
ping localhost -n 2 >nul
cls
call :GetInternational
call :GetSecs "%date%" "%time%" startTime3
goto showstatslog
) else (
call :GetSecs "%date%" "%time%" endTime2
call :GetInternational
call :GetSecs "%date%" "%time%" startTime3
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [_hosts file check status: Modified]>>"%logdir%"
set "_hostsfilecheckflag=Modified"
cls
goto showstatslog )







:showstatslog
if "%LoadingProcessbarmode%"=="Enabled" (
cls & echo Processing... & echo\ & echo [===================================^>   ]  95%%
) else (cls & echo Processing...)

echo\
echo Processing internet connection check... 
ping /n "%pinglayersnumber%" "%webhost%" >nul
if "%errorlevel%"=="0" set internetconnection=Connected
if "%errorlevel%"=="1" set internetconnection=Disconnected
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Internet connection current state: %internetconnection%]>>"%logdir%"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect current state: %directmode%]>>"%logdir%"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Ping layers current state: %pinglayersnumber%]>>"%logdir%"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Program height size current state: %heightsizemode%]>>"%logdir%"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Log file type current state: %logtype%]>>"%logdir%"
if "%LoadingProcessbarmode%"=="Enabled" (
cls & echo Processing... & echo\ & echo [====================================^>  ]  96%%
) else (cls & echo Processing...)
goto finishloadingStart

:finishloadingStart
if "%LoadingProcessbarmode%"=="Enabled" (
cls & echo Successfully loaded program^^! & echo\ & echo [======================================^>]  100%%
) else (cls & echo Successfully loaded program^^!)


if "%calcLoadingDurationmode%"=="Enabled" goto calcLoadDurationstart
goto checkautoupdate
:calcLoadDurationstart
call :GetSecs "%date%" "%time%" endTime3
echo\
set /a loadDuration1=(%endTime1%-%startTime1%)
set /a loadDuration2=(%endTime2%-%startTime2%)
set /a loadDuration3=(%endTime3%-%startTime3%)
set /a loadDuration=(%loadDuration1%+%loadDuration2%)+%loadDuration3%
echo Duration: %loadDuration% seconds
echo\
if "%loadDurationUI%"=="true" (
echo Caution: User input timestamps are not recorded^^! )
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Successfully loaded program^^! - Duration: %loadDuration% seconds]>>"%logdir%"
if "%loadDurationUI%"=="true" ping localhost -n 5 >nul
if "%loadDurationUI%"=="false" ping localhost -n 3 >nul

:checkautoupdate
if "%autoupdatemode%"=="Enabled" (set "autoupdateflag=true" &cls &goto checkupdate ) else (goto mainmenu )

::Main Menu START
:mainmenu
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Main menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -Main
call :header 17
echo\
echo              1. Hosts file manager
echo              2. Im hosts file manager
echo              3. Networks file manager
echo              4. Run in server mode
echo              5. Preferences
echo\
echo i/info t/tools
call :choice "12345itrq" "Make your selection: " ex
pause
if "%ex%"=="9" goto exit
if "%errorlevel%"=="8" cls & goto ADMIN
if "%errorlevel%"=="7" (set mainmenuvar=Tools
goto mainmenuloginput )
if "%errorlevel%"=="6" (set mainmenuvar=Show information
goto mainmenuloginput )
if "%errorlevel%"=="5" (set mainmenuvar=Preferences
goto mainmenuloginput )
if "%errorlevel%"=="4" (set mainmenuvar=Server mode
goto mainmenuloginput )
if "%errorlevel%"=="3" (set mainmenuvar=_networks file manager
goto mainmenuloginput )
if "%errorlevel%"=="2" (set mainmenuvar=_im_hosts file manager
goto mainmenuloginput )
if "%errorlevel%"=="1" (set mainmenuvar=_hosts file manager
goto mainmenuloginput )
:mainmenuloginput
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Main menu user input status: %mainmenuvar%]>>"%logdir%"
if "%errorlevel%"=="7" goto tools
if "%errorlevel%"=="6" goto infomenu
if "%errorlevel%"=="5" goto preferences
if "%errorlevel%"=="4" goto servermode
if "%errorlevel%"=="3" goto _networksManagerMainmenu
if "%errorlevel%"=="2" goto _im_hostsManagerMainmenu
if "%errorlevel%"=="1" goto _hostsManagerMainmenu
::Main Menu END


::Main Menu START
:_hostsManagerMainmenu
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Main menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -_hosts
call :header 17
echo\
echo            1. Enter a website to block
echo            2. Enter a website to unblock
echo            3. Clear all blocked websites
echo            4. Import and Export
echo            5. Hosts preferences
echo            6. Run _hosts file check
echo\
echo b/back
call :choice 123456b "Make your selection: " ex
if "%errorlevel%"=="7" (set mainmenuvar=Return to main menu
goto mainmenuloginput )
if "%errorlevel%"=="6" (set mainmenuvar=Run _hosts file check
goto mainmenuloginput )
if "%errorlevel%"=="5" (set mainmenuvar=_hosts preferences
goto mainmenuloginput )
if "%errorlevel%"=="4" (set mainmenuvar=Import and Export
goto mainmenuloginput )
if "%errorlevel%"=="3" (set mainmenuvar=Uninstall all blocked websites
goto mainmenuloginput )
if "%errorlevel%"=="2" (set mainmenuvar=Uninstall selected blocked websites
goto mainmenuloginput )
if "%errorlevel%"=="1" (set mainmenuvar=Enter a website to block
goto mainmenuloginput )
:mainmenuloginput
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Main menu user input status: %mainmenuvar%]>>"%logdir%"
if "%errorlevel%"=="7" goto mainmenu
if "%errorlevel%"=="6" goto Check_hostsFile
if "%errorlevel%"=="5" goto hostsPreferences
if "%errorlevel%"=="4" goto importexport
if "%errorlevel%"=="3" goto unblockall
if "%errorlevel%"=="2" goto unblockselected
if "%errorlevel%"=="1" goto blockwebsite
::Main Menu END

::Install Bocked Website START
:blockwebsite
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Block website menu status: Loaded menu]>>"%logdir%"
if not exist "%_hosts%" (
echo\>>"%_hosts%"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Block website menu status: Created _hosts file]>>"%logdir%" )
set "blockURL="
mode 52,%heightsizemode%
echo -Block
call :header 17
echo\
echo Current Redirect State: %directmode%
echo Listing Blocked Addresses...
type "%_hosts%"
echo\
echo b/back
echo Enter a website address:
set /p blockURL=www.
if "%blockURL%"=="" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Block website menu status: User entry is blank...]>>"%logdir%"
goto blockwebsite ) else if "%blockURL%"=="b" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Block website menu status: User backed out from block website menu]>>"%logdir%"
goto mainmenu ) else (
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Block website menu input website address: www.%blockURL%]>>"%logdir%" )
echo\
echo Processing...
echo\%blockURL%|findstr /rc:"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
if "%errorlevel%"=="0" (goto blockURLaddressprocessnotexist ) else (goto blockURLaddressnext )
:blockURLaddressnext
echo\%blockURL%|findstr /rc:"/" >nul
if "%errorlevel%"=="0" (goto blockURLaddressprocessnotexist ) else (goto blockURLaddressnext2 )
:blockURLaddressnext2
echo\%blockURL%|findstr /rc:"-" >nul
if "%errorlevel%"=="0" (goto blockURLaddressprocessnotexist ) else (goto blockURLaddressnext3 )
:blockURLaddressnext3
if "www.%blockURL%"=="%directmode%" goto blockAdressalreadyinstalled
goto blockURLaddressfindprocess
:blockAdressalreadyinstalled
echo You can not redirect a host to it's self...
ping localhost -n 2 >nul
echo Try a different host^^!
ping localhost -n 4 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Block website menu status: Address is already installed]>>"%logdir%"
goto blockwebsite
) else (goto blockURLaddressfindprocess )
:blockURLaddressfindprocess
findstr /i "%blockURL%" "%_hosts%" >nul
if "%errorlevel%"=="0" goto blockwebsitefound_hosts
if "%errorlevel%"=="1" goto blockwebsitecheckURL
:blockwebsitefound_hosts
echo Address is already installed...
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Block website menu status: Address is already installed]>>"%logdir%"
goto blockwebsite

:blockwebsitecheckURL
ping /n "%pinglayersnumber%" "%blockURL%" >nul
if "%errorlevel%"=="0" goto blockURLaddressprocessexist
if "%errorlevel%"=="1" goto blockURLaddressprocessnotexist

:blockURLaddressprocessexist
for /f "tokens=2delims=[]" %%i in ('ping /n "%pinglayersnumber%" "%blockURL%"^|find "["') do set "blockIPaddress=%%i"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Block website menu status: IP Address: %blockIPaddress%]>>"%logdir%"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Block website menu status: Address exists]>>"%logdir%"
goto blockwebsiteblockprocess
:blockURLaddressprocessnotexist
echo Connection to host does not exist...
ping localhost -n 2 >nul
echo Try a different host^^!
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Block website menu status: Address does not exist]>>"%logdir%"
goto blockwebsite

:blockwebsiteblockprocess
attrib -r "%_hosts%"
for %%a in (
www.%blockURL%
) do (
if "%directstate%"=="uilocalhost" echo %IPaddress% %%a>>"%_hosts%"
if "%directstate%"=="uiwebsite" echo %IPaddress% %directmode% %%a>>"%_hosts%"
if "%directstate%"=="uiIPaddess" echo %IPaddress% %%a>>"%_hosts%"
attrib +r "%_hosts%"
echo Done - Blocked New Address...
ping localhost -n 2 >nul
echo You may need to restart browser
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Block website menu status: Blocked website address: www.%blockURL%]>>"%logdir%"
cls 
goto mainmenu )
echo Error - Blocked New Address...
ping localhost -n 2 >nul
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Block website menu status: Error blocking address: www.%blockURL%]>>"%logdir%"
cls 
goto mainmenu )
::Install Bocked Website END

::Uninstall Selected Bocked Website START
:unblockselected
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Uninstall selected menu status: Loaded menu]>>"%logdir%"
if not exist "%_hosts%" (
echo\>>"%_hosts%"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Uninstall selected menu status: Created _hosts file]>>"%logdir%" )
set "unblockURL="
mode 52,%heightsizemode%
echo -Uninstall selected
call :header 17
echo\
echo Listing Blocked Addresses...
type "%_hosts%"
echo\
echo b/back
echo Enter the website to uninstall:
set /p unblockURL=www.
if "%unblockURL%"=="" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Uninstall selected menu status: User entry is blank...]>>"%logdir%"
goto unblockselected ) else if "%unblockURL%"=="b" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Uninstall selected menu status: User backed out from uninstall selected menu]>>"%logdir%"
goto mainmenu ) else (
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Uninstall selected menu status: Input website address: www.%unblockURL%]>>"%logdir%" )
echo\
echo Processing...
findstr /i /c:"www.%unblockURL%" "%_hosts%" >nul
if "%errorlevel%"=="1" (
echo Address is already uninstalled...
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Uninstall selected menu status: Address is already uninstalled]>>"%logdir%"
goto unblockselected )
attrib -r "%_hosts%"
for %%a in (
www.%unblockurl%
) do (
move "%_hosts%" "%_hosts%.bak" >nul
findstr /v /c:"%%a" "%_hosts%.bak">"%_hosts%"
del /f /q "%_hosts%.bak" )
attrib +r "%_hosts%"
echo Done - Cleared Selected Blocked Address^^!
ping localhost -n 2 >nul
echo You may need to restart browser
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Uninstall selected menu status: Removed website address: www.%unblockURL%]>>"%logdir%"
cls 
goto mainmenu
::Uninstall Selected Bocked Website END

::Uninstall All Bocked Website START
:unblockall
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Uninstall all menu status: Loaded menu]>>"%logdir%"
if not exist "%_hosts%" (
echo\>>"%_hosts%"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Uninstall all menu status: Created _hosts file]>>"%logdir%" )
mode 52,%heightsizemode%
echo -Uninstall all
call :header 17
echo\
echo Listing Blocked Addresses...
type "%_hosts%"
echo\
call :choice yn "Clear all blocked websites? Y/N: "
if "%errorlevel%"=="2" (
echo\
echo Cancelled - Returning to main menu...
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Uninstall all menu status: User backed out from uninstall all blocked website addresses...]>>"%logdir%"
goto mainmenu )
if "%errorlevel%"=="1" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Uninstall all menu status: User requests uninstall all blocked website addresses...]>>"%logdir%"
echo\
echo Processing...
attrib -r "%_hosts%"
if exist "%_hosts%" del /f /q "%_hosts%"
echo\>>"%_hosts%"
attrib +r "%_hosts%"
echo Done - Cleared All Blocked Addresses^^!
ping localhost -n 2 >nul
echo You may need to restart browser
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Uninstall all menu status: Unistalled all blocked website addresses]>>"%logdir%"
cls 
goto mainmenu )
::Uninstall All Bocked Website END

::Import And Export Website List START
:importexport
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export menu status: Loaded menu]>>"%logdir%"
mode 60,18
echo -Import/Export
call :header 21
echo\
echo              1. Import website list from file
echo              2. Export website list to file
echo\
echo b/back
call :choice 12b "Make your selection: "
if "%errorlevel%"=="3" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export menu status: User backed out import and export menu]>>"%logdir%"
goto mainmenu )
if "%errorlevel%"=="2" goto exportlist
if "%errorlevel%"=="1" goto importlist

::Import List File START
:importlist
echo\
echo Processing...
call :fileDialog "Im" "File" "*" "hf" "_hosts File"
if "%errorlevel%"=="0" REM Success
if "%errorlevel%"=="1" REM Failed
if "%errorlevel%"=="2" goto definedimportlist
if "%errorlevel%"=="3" goto notdefinedimportlist

:notdefinedimportlist
echo\
echo You did not choose a list file...
ping localhost -n 3 >nul
cls
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export status: User did not choose a list file to import]>>"%logdir%"
goto importexport )

:definedimportlist
echo You chose %FileName%
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export status: Import list file "%FileName%"]>>"%logdir%"
echo\
call :choice yn "Import exported file? Y/N: "
if "%errorlevel%"=="2" (
echo\
echo Cancelled - Returning to main menu...
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export status: User backed out from import list file "%FileName%"]>>"%logdir%"
goto importexport )
if "%errorlevel%"=="1" goto callimportexist
:callimportexist
set "HostFileName=%FileName%"
call :scanhostfile
if "%errorlevel%"=="0" (
echo\
echo Error - List file is corrupted...
echo\%FileName%
ping localhost -n 3 >nul
echo\
echo Please select another list file
ping localhost -n 4 >nul
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export status: Error importing import list file corrupted]>>"%logdir%"
goto importexport )
if not exist "%FileName%" (
echo\
echo Error - Could not find imported list file...
echo\%FileName%
ping localhost -n 3 >nul
echo\
echo Please select another list file
ping localhost -n 4 >nul
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export status: Error importing import list file could not be found]>>"%logdir%"
goto importexport )
if exist "%FileName%" (
attrib -r "%_hosts%"
if exist "%_hosts%" del /f "%_hosts%"
copy "%FileName%" "%_hosts%" >nul )
if "%errorlevel%"=="0" (
attrib +r "%_hosts%"
echo\
echo Done - Importing file...
ping localhost -n 2 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Import and Export status: Imported list file "%FileName%"]>>"%logdir%"
goto importexport )
if "%errorlevel%"=="1" (
echo\
echo Error - Access Denied importing file...
ping localhost -n 2 >nul
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export status: Error importing import list file Access Denied]>>"%logdir%"
goto Errorwritefiles )
::Import List File END

::Export List File START
:exportlist
echo\
echo Processing...
call :fileDialog "Ex" "File" "*" "hf" "_hosts File"
if "%errorlevel%"=="0" REM Success
if "%errorlevel%"=="1" REM Failed
if "%errorlevel%"=="2" goto definedexmportlist
if "%errorlevel%"=="3" goto notdefinedexmportlist

:notdefinedexmportlist
echo\
echo You did not save a list file...
ping localhost -n 3 >nul
cls
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export status: User did not choose a list file to export]>>"%logdir%"
goto importexport )

:definedexmportlist
echo Exporting list file to...
echo %FileName%
ping localhost -n 2 >nul
if not exist "%FileName%" goto replaceexport
if exist "%FileName%" goto replaceexportexist
:replaceexportexist
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export status: Export list file "%FileName%"]>>"%logdir%"
echo\
call :choice yn "Replace exported file? Y/N: "
if "%errorlevel%"=="2" (
echo\
echo Cancelled - Returning to main menu...
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export status: User backed out from delete export list file]>>"%logdir%"
goto importexport )
if "%errorlevel%"=="1" goto deleteexportexist
:deleteexportexist
if exist "%FileName%" del "%FileName%" >nul
if "%errorlevel%"=="1" (
:deleteexportexistError
echo Error - Replacing file...
ping localhost -n 2 >nul
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Import and Export status: Error replacing export list file "%FileName%"]>>"%logdir%"
goto Errorwritefiles )
if "%errorlevel%"=="0" goto replaceexport
:replaceexport
if not exist "%_hosts%" (
echo\
echo Error - Please restart the program^^!
ping localhost -n 3 >nul
goto exit )
if exist "%_hosts%" copy "%_hosts%" "%FileName%" /a /v >nul
if "%errorlevel%"=="0" goto doendeleteexportexist
if "%errorlevel%"=="1" goto deleteexportexistError
:doendeleteexportexist
attrib +r "%FileName%"
echo\
echo Done - Exporting file...
ping localhost -n 2 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Import and Export status: Exported list file "%FileName%"]>>"%logdir%"
goto importexport )
::Export List File END
::Import And Export Website List END




:_im_hostsManagerMainmenu














:_networksManagerMainmenu
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Main menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -_networks
call :header 17
echo\
echo            1. Enter a new mapping entry
echo            2. Remove a new mapping entry
echo            3. Clear all mapping entries
echo            4. Import and Export
echo            5. Preferences
echo\
echo b/back
call :choice 123456b "Make your selection: "
if "%errorlevel%"=="7" (set mainmenuvar=Return to main menu
goto mainmenuloginput )
if "%errorlevel%"=="6" (set mainmenuvar=Preferences
goto mainmenuloginput )
if "%errorlevel%"=="5" (set mainmenuvar=Server mode
goto mainmenuloginput )
if "%errorlevel%"=="4" (set mainmenuvar=Import and Export
goto mainmenuloginput )
if "%errorlevel%"=="3" (set mainmenuvar=Uninstall all blocked websites
goto mainmenuloginput )
if "%errorlevel%"=="2" (set mainmenuvar=Uninstall selected blocked websites
goto mainmenuloginput )
if "%errorlevel%"=="1" (set mainmenuvar=Enter a website to block
goto mainmenuloginput )
:mainmenuloginput
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Main menu user input status: %mainmenuvar%]>>"%logdir%"
if "%errorlevel%"=="7" goto mainmenu
if "%errorlevel%"=="6" goto preferences
if "%errorlevel%"=="5" goto servermode
if "%errorlevel%"=="4" goto importexport
if "%errorlevel%"=="3" goto unblockall
if "%errorlevel%"=="2" goto unblockselected
if "%errorlevel%"=="1" goto blockwebsite


::Server mode START
:servermode
cls
echo -Server
call :header 17
echo\
call :choice yn "Run in server mode? Y/N: "
if "%errorlevel%"=="2" goto mainmenu
if "%errorlevel%"=="1" goto startServer

:startServer
mode 52,30
echo -Server
echo                  ---- Trinity ----
echo\
echo Starting server...
pause


REM Modes:
::_hostsMode
::_im_hostsMode
::_networksMode

goto mainmenu














::Server mode END



::Preferences START
:preferences
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Preferences menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -Preferences
call :header 17
echo\
echo                 1. General Options
echo                 2. Host Options
echo                 3. Loading Options
echo                 4. User Language
echo\
echo b/back
call :choice 123b "Make your selection: "
if "%errorlevel%"=="4" (set preferencesmenuvar=Return main menu
goto preferencesmenuloginput )
if "%errorlevel%"=="3" (set preferencesmenuvar=Loading Options
set "savepinglayerflag=false"
goto preferencesmenuloginput )
if "%errorlevel%"=="2" (set preferencesmenuvar=Host Options
set "saveprogrampasswordflag=false"
goto preferencesmenuloginput )
if "%errorlevel%"=="1" (set preferencesmenuvar=General Options
set "savelogmodeflag=false"
goto preferencesmenuloginput )
:preferencesmenuloginput
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Preferences menu user options input status: %preferencesmenuvar%]>>"%logdir%"
if "%errorlevel%"=="4" goto mainmenu
if "%errorlevel%"=="3" goto UILanguagePreferences
if "%errorlevel%"=="2" goto LoadingPreferences
if "%errorlevel%"=="1" goto GeneralPreferences
::Preferences END

::General Options START
:GeneralPreferences
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [General preferences menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -General
call :header 17
echo\
echo            1. Change log file mode
echo            2. Change program's password mode
echo            3. Change ping Layer's
echo            4. Change program height size
echo            5. Change auto-update mode
echo\
echo b/back
call :choice 12345b "Make your selection: "
if "%errorlevel%"=="6" (set GeneralPreferencesMVar=Return main preferences menu
goto GeneralPreferencesLI )
if "%errorlevel%"=="5" (set GeneralPreferencesMVar=Change auto-update
goto GeneralPreferencesLI )
if "%errorlevel%"=="4" (set GeneralPreferencesMVar=Change program height size
goto GeneralPreferencesLI )
if "%errorlevel%"=="3" (set GeneralPreferencesMVar=Change ping layers
goto GeneralPreferencesLI )
if "%errorlevel%"=="2" (set GeneralPreferencesMVar=Change programs password
goto GeneralPreferencesLI )
if "%errorlevel%"=="1" (set GeneralPreferencesMVar=Change log file mode
goto GeneralPreferencesLI )
:GeneralPreferencesLI
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [General preferences menu user input status: %GeneralPreferencesMVar%]>>"%logdir%"
if "%errorlevel%"=="6" goto preferences
if "%errorlevel%"=="5" goto changeautoupdate
if "%errorlevel%"=="4" goto changeprogramheightsize
if "%errorlevel%"=="3" goto changepinglayers
if "%errorlevel%"=="2" goto changepassword
if "%errorlevel%"=="1" goto changelogfilemode
::General Options END

::Change log file mode START
:changelogfilemode
call :checkLogModeReg
call :checkLogTypeReg
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change log file mode menu status: Loaded menu]>>"%logdir%"
mode 52,15
echo -Log mode
call :header 17
echo\
echo           Current State: %logmode%:%logtype%
echo\
echo               1. Enable programs log
echo               2. Disable programs log
echo               3. Change log type
echo\
echo b/back
call :choice 123b "Make your selection: "
if errorlevel 4 (
echo\
if "%savelogmodeflag%"=="true" (
echo Saved - Returning to preferences menu...
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change log file mode menu status: User saved programs log mode settings]>>"%logdir%"
) else (
echo Returning to preferences menu...
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change log file mode menu status: User returned preferences menu]>>"%logdir%" )
ping localhost -n 2 >nul
cls
goto preferences )
if errorlevel 3 goto logmodetypesort
if errorlevel 2 goto disablelog
if errorlevel 1 goto enablelog

:enablelog
call :checkLogModeReg
if "%logmode%"=="Enabled" goto changelogfilemode
if "%logmode%"=="Disabled"  (
set logmode=Enabled
call :checkfileUAC /l && echo [%time%] [Change log file mode menu status: Enabled log]>>"%logdir%"
goto savechangelogmode )
:disablelog
call :checkLogModeReg
if "%logmode%"=="Disabled" goto changelogfilemode
if "%logmode%"=="Enabled" (
set logmode=Disabled
call :checkfileUAC /l && echo [%time%] [Change log file mode menu status: Disabled log]>>"%logdir%"
goto savechangelogmode )

:logmodetypesort
call :checkLogtypeReg
if "%logtype%"=="Detailed" goto logmodetypeDetailed
if "%logtype%"=="General" goto logmodetypeGeneral
:logmodetypeDetailed
set logtype=General
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change log file mode menu status: Log type General]>>"%logdir%"
goto savechangelogtype
:logmodetypeGeneral
set logtype=Detailed
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change log file mode menu status: Log type Detailed]>>"%logdir%"
goto savechangelogtype

:savechangelogmode
set "savelogmodeflag=true"
>nul reg add "%RegKey%" /v "LOG_MODE" /t REG_SZ /d "%logmode%" /f
goto changelogfilemode

:savechangelogtype
set "savelogmodeflag=true"
>nul reg add "%RegKey%" /v "LOG_TYPE" /t REG_SZ /d "%logtype%" /f
goto changelogfilemode
::Change log file mode END

::Change Programs Password START
:changepassword
call :checkCharMapReg
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change program password menu status: Loaded menu]>>"%logdir%"
set "currentpass="
set "passvar1="
set "passvar2="
mode 52,20
echo -Change password
call :header 17
echo\
echo          Current State: %passwordmode%:%passcharmapmode%
echo\
echo            1. Disable password on program  
echo            2. Set password for program
echo            3. Change characters with "*"
echo\
echo b/back
call :choice 123b "Make your selection: "
if errorlevel 4 (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change program password menu status: User returned preferences menu]>>"%logdir%" )
cls & goto preferences )
if errorlevel 3 goto changepasscharmap
if errorlevel 2 goto setpassword
if errorlevel 1 goto disablepassword


::Disable program password START
:disablepassword
if "%passwordmode%"=="Enabled" goto passdisableenabled
if "%passwordmode%"=="Disabled" goto changepassword
:passdisableenabled
echo Enter current password:
set /p currentpass=
if "%currentpass%"=="" goto changepassword
call :DecryptPassword
if "%passencryptmap%"=="Enabled" (
if "%currentpass%"=="%DecryptOut%" (
call :disablepasswordfunction0
) else (
call :disablepasswordfunction1 ) )
if "%currentpass%"=="%passwordvar%" (
call :disablepasswordfunction0
) else (
call :disablepasswordfunction1 )
:disablepasswordfunction0
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change program password menu status: Disable password user input: Entry correct]>>"%logdir%"
echo Done - Disabled password^^!
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change program password menu status: Disabled password]>>"%logdir%"
set "passwordmode=Disabled"
set "passmodevar=false"
goto savepassmodefile
:disablepasswordfunction1
echo Error - Incorrent password^^!
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change program password menu status: Disable password user input: Entry incorrect]>>"%logdir%"
goto changepassword
::Disable program password START

::Set program password START
:setpassword
if "%passwordmode%"=="Enabled" goto passsetenabledcurrent
if "%passwordmode%"=="Disabled" goto passsetenableentry
:passsetenabledcurrent
echo Enter current password:
set /p currentpass=
if "%currentpass%"=="" goto changepassword
call :DecryptPassword
if "%passencryptmap%"=="Enabled" (
if "%currentpass%"=="%DecryptOut%" (
call :setpasswordfunction0
) else (
call :setpasswordfunction1 ) )
if "%currentpass%"=="%passwordvar%" (
call :setpasswordfunction0
) else (
call :setpasswordfunction1 )
:setpasswordfunction0
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change program password menu status: Enable password user input: Entry correct]>>"%logdir%"
goto passsetenableentry
:setpasswordfunction1
echo Error - Incorrent password^^!
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change program password menu status: Enable password user input: Entry incorrect]>>"%logdir%"
goto changepassword
:passsetenableentry
echo Enter new password:
set /p passvar1=
if "%passvar1%"=="%enclode%" goto passreserved
if "%passvar1%"=="%comp%" goto passreserved
echo Confirm:
set /p passvar2=
if "%passvar1%"=="" goto changepassword
if "%passvar2%"=="" goto changepassword
if "%passvar1%"=="%passvar2%" (
echo Done - Saved new password^^!
if "%passencryptmap%"=="Enabled" (
set "Encrypt2=%passvar1%"
call :EncryptKeysV2
call :EncryptFunction )
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change program password menu status: Enabled password]>>"%logdir%"
set "passwordmode=Enabled"
set "passmodevar=true"
goto savepassmodefile
) else (
echo Error - Password did not match^^!
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change program password menu status: Enable password user input: Entry incorrect]>>"%logdir%"
goto changepassword )

:passreserved
echo Error - Not allowed^^!
ping localhost -n 2 >nul
cls
goto changepassword
::Set program password END

:savepassmodefile
set "saveprogrampasswordflag=true"
attrib -r "%passfile%"
if exist "%passfile%" del "%passfile%"
if "%passmodevar%"=="true" echo set "passwordvar=%EncryptOut%">>"%passfile%"
echo set "passwordmode=%passwordmode%">>"%passfile%"
attrib +r "%passfile%"



goto changepassword

:enablecalcDuration
call :checkcalcDurationReg "/r"
if "%calcLoadingDurationmode%"=="Enabled" goto calcLoadingDuration
if "%calcLoadingDurationmode%"=="Disabled"  (
set calcLoadingDurationmode=Enabled
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change Loading process bar menu status: Enabled auto-update]>>"%logdir%"
goto savecalcDuration )
:disablecalcDuration
call :checkcalcDurationReg "/r"
if "%calcLoadingDurationmode%"=="Disabled" goto calcLoadingDuration
if "%calcLoadingDurationmode%"=="Enabled" (
set calcLoadingDurationmode=Disabled
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change auto-update menu status: Disabled auto-update]>>"%logdir%"
goto savecalcDuration )

:savecalcDuration
>nul reg add "%RegKey%" /v "CALC_LOADING_DURATION" /t REG_SZ /d "%calcLoadingDurationmode%" /f
goto calcLoadingDuration










:changepasscharmap
if "%passcharmapmode%"=="Enabled" goto passcharmapDisable
if "%passcharmapmode%"=="Disabled" goto passcharmapEnable
if exist "%logmodefile%" del "%logmodefile%"
:passcharmapEnable
set "passcharmapmode=Enabled"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Character mapping mode menu status: Enabled]>>"%logdir%"
goto savepasscharmap
:passcharmapDisable
set "passcharmapmode=Disabled"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Character mapping mode menu status: Disabled]>>"%logdir%"
goto savepasscharmap

:savepasscharmap
set "saveprogrampasswordflag=true"
>nul reg add "%RegKey%" /v "CHARACTER_MAP" /t REG_SZ /d "%passcharmapmode%" /f
goto changepassword
::Change Programs Password END

::Change Ping Layers START
:changepinglayers
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change ping layers menu status: Loaded menu]>>"%logdir%"
call :checkPingLayersReg "r"
call :checkPingLayersReg "dm"
set "pinglayers="
mode 52,13
echo -Change ping
call :header 17
echo\
echo Current State: %pinglayersnumber%
echo\
echo b/back i/info
echo Enter amount of layers (%pinglayersmin%-%pinglayersmax% MAX):
set /p pinglayers=
if "%pinglayers%"=="" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change ping layers menu status: User entry is blank...]>>"%logdir%"
goto changepinglayers )
if "%pinglayers%"=="b" (
echo\
if "%savepinglayerflag%"=="true" (
echo Saved - Returning to preferences menu...
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change ping layers menu status: User saved program ping layers settings]>>"%logdir%"
) else (
echo Returning to preferences menu...
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change ping layers menu status: User returned preferences menu]>>"%logdir%" )
ping localhost -n 2 >nul
cls
goto preferences )
if "%pinglayers%"=="i" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change ping layers menu status: User requests to view infomation guide...]>>"%logdir%"
cls
goto changepinglayersinfo
) else (
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change ping layers menu status input layer: %pinglayers%]>>"%logdir%"
set /a "numeric=pinglayers" 2>nul && (
  if "!numeric!"=="!pinglayers!" (
    if !numeric! geq %pinglayersmin% (
      if !numeric! leq %pinglayersmax% (
	  set "savepinglayerflag=true"
		>nul reg add "%RegKey%" /v "PING_PLAYERS" /t REG_SZ /d "%pinglayers%" /f
      ) else (
        goto changepinglayers1
      )
    ) else (
      goto changepinglayers1
    )
  ) else (
    goto changepinglayers1
  )
) || (
  exit /b
)
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change ping layers menu status current state: %pinglayersnumber%]>>"%logdir%"
goto changepinglayers )

:changepinglayers1
reg query "%RegKey%" /v "PING_PLAYERS" >nul 2>nul
if "%errorlevel%"=="0" for /f "tokens=2*" %%i in ('reg query "%RegKey%" /v "PING_PLAYERS"') do set "pinglayersnumber=%%j"
goto changepinglayers

:changepinglayersinfo
mode 55,18
cls
echo -About ping
echo\
echo Ping is a General Internet program that allows a user 
echo to verify that a particular IP address exists and can
echo accept requests.
echo\
echo Setting the ping layers is the amount of packets sent
echo to the host. Now if you have a fast internet line I
echo would recomend a layer of 2 and if you have a slower
echo internet speed, differs on your line try a higher 
echo layer. The lower you set it if you have a slower
echo internet speed the greater the risks of the program
echo erroring out that it could not connect to the host.
echo You can set it from layers %pinglayersmin%-%pinglayersmax%.
echo\
pause
cls
goto changepinglayers
::Change Ping Layers END

::Change program height size START
:changeprogramheightsize
call :checkHeightSizeReg
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change program height size menu status: Loaded menu]>>"%logdir%"
call :HeightSizeMaxMin
set "heightsize="
mode 52,13
echo -Change height size
call :header 17
echo\
echo Current State: %heightsizemode%
echo\
echo b/back v/view
echo Enter amount of layers (%heightsizemin%-%heightsizemax% MAX):
set /p heightsize=
if "%heightsize%"=="" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change program height size menu status: User entry is blank...]>>"%logdir%"
goto changeprogramheightsize )
if "%heightsize%"=="b" (
echo\
if "%saveheightsizeflag%"=="true" (
echo Saved - Returning to preferences menu...
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change program height size menu status: User saved program height size settings]>>"%logdir%"
) else (
echo Returning to preferences menu...
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change program height size menu status: User returned preferences menu]>>"%logdir%" )
ping localhost -n 2 >nul
cls
goto preferences )
if "%heightsize%"=="v" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change program height size menu status: User requests to view infomation guide...]>>"%logdir%"
cls
goto changeprogramheightsizeview
) else (
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change program height size menu status input layer: %heightsize%]>>"%logdir%"
set /a "numeric=heightsize" 2>nul && (
  if "!numeric!"=="!heightsize!" (
    if !numeric! geq %heightsizemin% (
      if !numeric! leq %heightsizemax% (
	  set "saveheightsizeflag=true"
		>nul reg add "%RegKey%" /v "HEIGHT_SIZE" /t REG_SZ /d "%heightsize%" /f
      ) else (
        goto changeprogramheightsize1
      )
    ) else (
      goto changeprogramheightsize1
    )
  ) else (
    goto changeprogramheightsize1
  )
) || (
  exit /b
)
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change program height size menu status current state: %heightsizemode%]>>"%logdir%"
goto changeprogramheightsize )

:changeprogramheightsize1
reg query "%RegKey%" /v "HEIGHT_SIZE" >nul 2>nul
if "%errorlevel%"=="0" for /f "tokens=2*" %%i in ('reg query "%RegKey%" /v "HEIGHT_SIZE"') do set "heightsizemode=%%j"
goto changeprogramheightsize

:changeprogramheightsizeview
mode 52,%heightsizemode%
cls
echo -Height size preview
call :header 17
echo\
echo Listing Blocked Addresses...
type "%_hosts%"
echo\
pause
cls
goto changeprogramheightsize
::Change program height size END

::Change Auto-update settings START
:changeautoupdate
call :checkAutoUpdateReg "/r"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change auto-update menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -Auto-update
call :header 17
echo\
echo               Current State: %autoupdatemode%
echo\
echo            1. Enable auto-update checks
echo            2. Disable auto-update checks
echo\
echo b/back
call :choice 12b "Make your selection: "
if errorlevel 3 (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change auto-update menu status: User returned preferences menu]>>"%logdir%"
cls & goto GeneralPreferences )
if errorlevel 2 goto disableautoupdate
if errorlevel 1 goto enableautoupdate

:enableautoupdate
call :checkAutoUpdateReg "/r"
if "%autoupdatemode%"=="Enabled" goto changeautoupdate
if "%autoupdatemode%"=="Disabled"  (
set autoupdatemode=Enabled
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change auto-update menu status: Enabled auto-update]>>"%logdir%"
goto saveautoupdate )
:disableautoupdate
call :checkAutoUpdateReg "/r"
if "%autoupdatemode%"=="Disabled" goto changeautoupdate
if "%autoupdatemode%"=="Enabled" (
set autoupdatemode=Disabled
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change auto-update menu status: Disabled auto-update]>>"%logdir%"
goto saveautoupdate )

:saveautoupdate
>nul reg add "%RegKey%" /v "AUTO_UPDATE" /t REG_SZ /d "%autoupdatemode%" /f
goto changeautoupdate
::Change Auto-update settings END


::Loading Options START
:LoadingPreferences
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Loading preferences menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -Loading
call :header 17
echo\
echo                1. Show Process bar
echo                2. Calculate Duration
echo\
echo b/back
call :choice 12b "Make your selection: "
if "%errorlevel%"=="3" (set LoadingPreferencesMVar=Return main preferences menu
goto LoadingPreferencesLI )
if "%errorlevel%"=="2" (set LoadingPreferencesMVar=
goto LoadingPreferencesLI )
if "%errorlevel%"=="1" (set LoadingPreferencesMVar=
goto LoadingPreferencesLI )
:LoadingPreferencesLI
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Loading preferences menu user input status: %LoadingPreferencesMVar%]>>"%logdir%"
if "%errorlevel%"=="3" goto preferences
if "%errorlevel%"=="2" goto calcLoadingDuration
if "%errorlevel%"=="1" goto showLoadingProcessbar
::General Options END


:showLoadingProcessbar
call :checkLoadBarReg "/r"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change Loading process bar menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -Process Bar
call :header 17
echo\
echo               Current State: %LoadingProcessbarmode%
echo\
echo          1. Enable loading process bar
echo          2. Disable loading process bar
echo\
echo b/back
call :choice 12b "Make your selection: "
if "%errorlevel%"=="3" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change Loading process bar menu status: User returned preferences menu]>>"%logdir%"
cls & goto LoadingPreferences )
if "%errorlevel%"=="2" goto disableLoadBar
if "%errorlevel%"=="1" goto enableLoadBar

:enableLoadBar
call :checkLoadBarReg "/r"
if "%LoadingProcessbarmode%"=="Enabled" goto showLoadingProcessbar
if "%LoadingProcessbarmode%"=="Disabled"  (
set LoadingProcessbarmode=Enabled
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change Loading process bar menu status: Enabled auto-update]>>"%logdir%"
goto saveLoadBar )
:disableLoadBar
call :checkLoadBarReg "/r"
if "%LoadingProcessbarmode%"=="Disabled" goto showLoadingProcessbar
if "%LoadingProcessbarmode%"=="Enabled" (
set LoadingProcessbarmode=Disabled
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change auto-update menu status: Disabled auto-update]>>"%logdir%"
goto saveLoadBar )

:saveLoadBar
>nul reg add "%RegKey%" /v "LOADING_PROCESS_BAR" /t REG_SZ /d "%LoadingProcessbarmode%" /f
goto showLoadingProcessbar


:calcLoadingDuration
call :checkcalcDurationReg "/r"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change Loading process bar menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -Duration Calc
call :header 17
echo\
echo               Current State: %calcLoadingDurationmode%
echo\
echo          1. Enable loading process bar
echo          2. Disable loading process bar
echo\
echo b/back
call :choice 12b "Make your selection: "
if "%errorlevel%"=="3" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change Loading process bar menu status: User returned preferences menu]>>"%logdir%"
cls & goto LoadingPreferences )
if "%errorlevel%"=="2" goto disablecalcDuration
if "%errorlevel%"=="1" goto enablecalcDuration

:enablecalcDuration
call :checkcalcDurationReg "/r"
if "%calcLoadingDurationmode%"=="Enabled" goto calcLoadingDuration
if "%calcLoadingDurationmode%"=="Disabled"  (
set calcLoadingDurationmode=Enabled
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change Loading process bar menu status: Enabled auto-update]>>"%logdir%"
goto savecalcDuration )
:disablecalcDuration
call :checkcalcDurationReg "/r"
if "%calcLoadingDurationmode%"=="Disabled" goto calcLoadingDuration
if "%calcLoadingDurationmode%"=="Enabled" (
set calcLoadingDurationmode=Disabled
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change auto-update menu status: Disabled auto-update]>>"%logdir%"
goto savecalcDuration )

:savecalcDuration
>nul reg add "%RegKey%" /v "CALC_LOADING_DURATION" /t REG_SZ /d "%calcLoadingDurationmode%" /f
goto calcLoadingDuration




:UILanguagePreferences
::call :checkAutoUpdateReg "/r"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change auto-update menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -Language
call :header 17
echo\
echo               Current State: %UILanguage%
echo\
echo               1. English   4. Arabic
echo               2. Mandarin  5. French
echo               3. Spanish   6. German
echo\
call :choice 123456b "Make your selection: "
if "%errorlevel%"=="3" (set LoadingPreferencesMVar=Return main preferences menu
goto LoadingPreferencesLI )
if "%errorlevel%"=="2" (set LoadingPreferencesMVar=
goto LoadingPreferencesLI )
if "%errorlevel%"=="1" (set LoadingPreferencesMVar=
goto LoadingPreferencesLI )
:LoadingPreferencesLI
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Loading preferences menu user input status: %LoadingPreferencesMVar%]>>"%logdir%"
if "%errorlevel%"=="7" goto GeneralPreferences
if "%errorlevel%"=="6" goto GeneralPreferences
if "%errorlevel%"=="5" goto GeneralPreferences
if "%errorlevel%"=="4" goto GeneralPreferences
if "%errorlevel%"=="3" goto GeneralPreferences
if "%errorlevel%"=="2" goto calcLoadingDuration
if "%errorlevel%"=="1" goto showLoadingProcessbar







::Host Options START
:hostsPreferences
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Host preferences menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -_hosts
call :header 17
echo\
echo                1. Redirect options   
echo                2. Host Options
echo                2. DNS comparison2IP
echo\
echo b/back
call :choice 123b "Make your selection: "
set errorlevel=%errorlevel%
if "%errorlevel%"=="4" (set HostPreferencesMVar=Return main preferences menu
goto HostPreferencesLI )
if "%errorlevel%"=="3" (set HostPreferencesMVar=
goto HostPreferencesLI )
if "%errorlevel%"=="2" (set HostPreferencesMVar=
goto HostPreferencesLI )
if "%errorlevel%"=="1" (set HostPreferencesMVar=
goto HostPreferencesLI )
:HostPreferencesLI
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Host preferences menu user input status: %HostPreferencesMVar%]>>"%logdir%"
if "%errorlevel%"=="4" goto preferences
if "%errorlevel%"=="3" goto 
if "%errorlevel%"=="2" goto 
if "%errorlevel%"=="1" goto 
::Host Options END


:RedirectPreferences
if "%uilocalhostflag%"=="true" goto redirectflagtrue
if "%uilocalhostflag%"=="false" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect menu status: Loaded menu]>>"%logdir%" )
:redirectflagtrue
mode 52,20
echo -Redirect
call :header 17
echo\
echo           Current State: %directmode%
echo\
echo           1. Redirect to a website
echo           2. Redirect to blank page
echo           3. Enter IP Address of a server
echo\
echo b/back
call :choice 123b "Make your selection: "
set errorlevel=%errorlevel%


if "%errorlevel%"=="4" (set HostPreferencesMVar=Return main preferences menu
goto HostPreferencesLI )
if "%errorlevel%"=="3" (set HostPreferencesMVar=
goto HostPreferencesLI )
if "%errorlevel%"=="2" (set HostPreferencesMVar=
goto HostPreferencesLI )
if "%errorlevel%"=="1" (set HostPreferencesMVar=
goto HostPreferencesLI )
:HostPreferencesLI
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Host preferences menu user input status: %HostPreferencesMVar%]>>"%logdir%"
if "%errorlevel%"=="4" goto preferences
if "%errorlevel%"=="3" goto 
if "%errorlevel%"=="2" goto 
if "%errorlevel%"=="1" goto 

if "%errorlevel%"=="4 (
set uilocalhostflag=false
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect menu status: User saved redirect menu settings]>>"%logdir%"
cls & goto mainmenu )
if "%errorlevel%"=="3" goto redirectenterIP
if "%errorlevel%"=="2" goto redirectenterlocalhost
if "%errorlevel%"=="1" goto redirectenterURL






::Redirect website to option (local-host or another domain) START
:redirectenterURL
set redirectURLflag=false
set "redirectURL="
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect menu status: User requests enter website address...]>>"%logdir%"
echo\
echo b/back
echo Enter a website address:
set /p redirectURL=www.
if "%redirectURL%"=="" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect menu status: User entry is blank...]>>"%logdir%"
goto redirect ) else if "%redirectURL%"=="b" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect menu status: User backed out from redirect to website]>>"%logdir%"
goto redirect ) else (
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Redirect menu status input website address: www.%redirectURL%]>>"%logdir%" )
echo\
echo Processing...
echo\%redirectURL%|findstr /rc:"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
if "%errorlevel%"=="0" (goto redirectenterURLprocess1 ) else (goto redirectURLnext )
:redirectURLnext
echo\%redirectURL%|findstr /rc:"/" >nul
if "%errorlevel%"=="0" (goto redirectenterURLprocess1 ) else (goto redirectURLnext2 )
:redirectURLnext2
echo\%redirectURL%|findstr /rc:"-" >nul
if "%errorlevel%"=="0" (goto redirectenterURLprocess1 ) else (goto redirectenterURLprocess )

:redirectenterURLprocess
ping /n "%pinglayersnumber%" "%redirectURL%" >nul
if "%errorlevel%"=="0" goto redirectenterURLprocess0
if "%errorlevel%"=="1" goto redirectenterURLprocess1

:redirectenterURLprocess0
for /f "tokens=2delims=[]" %%i in ('ping /n "%pinglayersnumber%" "%redirectURL%"^|find "["') do set "IPaddress=%%i"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect menu status: IP Address: %IPaddress%]>>"%logdir%"
set directmode=www.%redirectURL%
set directstate=uiwebsite
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Redirect menu status: Address does exist]>>"%logdir%"
goto saveredirectfile
:redirectenterURLprocess1
echo Connection to host does not exist^^!
ping localhost -n 2 >nul
echo Try a different host!
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Redirect menu status: Address does not exist]>>"%logdir%"
goto redirect


:redirectenterlocalhost
if not "%directstate%"=="uilocalhost" (
set uilocalhostflag=false
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Redirect menu status: User set redirect to blank page]>>"%logdir%" )
set directmode=Blank Page
set directstate=uilocalhost
set IPaddress=127.0.0.1
set uilocalhostflag=true
goto saveredirectfile


:redirectenterIP
set "redirectIP="
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect menu status: User requests enter IP Address...]>>"%logdir%"
echo\
echo b/back
echo Enter a IP address:
set /p redirectIP=
if "%redirectIP%"=="" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect menu status: User entry is blank...]>>"%logdir%"
goto redirect ) else if "%redirectIP%"=="b" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect menu status: User backed out from redirect IP Address menu]>>"%logdir%"
goto redirect ) else (
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Redirect menu status input IP Address: %redirectIP%]>>"%logdir%" )
echo\
echo Processing...
echo\%redirectIP%|findstr /rc:"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
if "%errorlevel%"=="0" (goto redirectenterIPnext ) else (goto redirectIPstructure )
:redirectenterIPnext
echo\%redirectIP%|findstr /rc:"/" >nul
if "%errorlevel%"=="0" (goto redirectIPstructure ) else (goto redirectenterIPnext2 )
:redirectenterIPnext2
echo\%redirectIP%|findstr /rc:"-" >nul
if "%errorlevel%"=="0" (goto redirectIPstructure ) else (goto redirectenterIPprocess )

:redirectenterIPprocess
ping /n "%pinglayersnumber%" "%redirectIP%" >nul
if "%errorlevel%"=="0" goto redirectenterIPprocessnext2
if "%errorlevel%"=="1" goto redirectenterIPprocess1
:redirectenterIPprocessnext2
ping /n "%pinglayersnumber%" "%redirectIP%"|findstr /i "Destination host unreachable." >nul
if "%errorlevel%"=="1" goto redirectenterIPprocess0
if "%errorlevel%"=="0" goto redirectenterIPprocess1
:redirectenterIPprocess0
set directmode=%redirectIP%
set directstate=uiIPaddess
set IPaddress=%redirectIP%
cls
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Redirect menu status: IP Address is valid!]>>"%logdir%"
goto saveredirectfile
:redirectenterIPprocess1
echo IP Address is invalid...
ping localhost -n 2 >nul
echo Try a different IP Address^^!
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Redirect menu status: IP Address is invalid]>>"%logdir%"
goto redirect 
:redirectIPstructure
echo IP Address structure is invalid...
ping localhost -n 2 >nul
echo Correct it^^!
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Redirect menu status: IP Address structure is invalid]>>"%logdir%"
goto redirect


:saveredirectfile
call :checkDirectModeReg
call :checkDirectStateReg
call :checkIPAddressReg
goto redirect
::Redirect website to option (local-host or another domain) END

:Check_hostsFile


exit /b



::Tools START
:tools
call :checkfileUAC /l && if "%logmode%"=="Enable" if "%logtype%"=="Detailed" echo [%time%] [Tools menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -Tools
call :header 17   
echo\
echo\           1. %_OS% Activation Status
echo            2. User account password tool
echo            3. Ping a website
echo            4. Display PC's on network
echo            5. Plugin manager
echo\
echo b/back
call :choice 1234b "Make your selection: "
if errorlevel 6 ( set toolsmenuvar=Return main menu
goto toolsmenuloginput )
if errorlevel 5 ( set toolsmenuvar=Plugin manager
goto toolsmenuloginput )
if errorlevel 4 ( set toolsmenuvar=Display network users
goto toolsmenuloginput )
if errorlevel 3 ( set toolsmenuvar=Ping website
goto toolsmenuloginput )
if errorlevel 2 ( set toolsmenuvar=Change or Remove PC's user password
goto toolsmenuloginput )
if errorlevel 1 ( set toolsmenuvar=%_OS% Activation Status
goto toolsmenuloginput )
:toolsmenuloginput
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Tools menu user input status: %toolsmenuvar%]>>"%logdir%"
if errorlevel 6 goto mainmenu
if errorlevel 5 goto pluginmanger
if errorlevel 4 goto shownetworkusers
if errorlevel 3 goto pingwebsite
if errorlevel 2 goto PCuserpassword
if errorlevel 1 goto windowsactivation
::Tools END

::Display Windows Activation Status START
:windowsactivation
if not exist "%_slmgr%" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Windows activation menu status: Error containing windows activation information]>>"%logdir%"
echo Error - Could not contain Windows Activation Status
ping localhost -n 3 >nul
cls
goto tools
) else ( goto windowsactivation0 )
:windowsactivation0
set hyphencount=71
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Windows activation menu status: Contained windows activation information]>>"%logdir%"
mode 72,20
echo\
echo Checking %_OS% Activation Status...
set "hyphens="
for /l %%i in (1 1 %hyphencount%) do set "hyphens=!hyphens!-"
set "hyphens=%hyphens%"
echo\%hyphens%
call :getwindowsactivation
call :GetProductKey sWinProdKey
for /f "tokens=3" %%p in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v ProductID') do set "ProductID=%%p">nul
echo Product ID: %ProductID%
echo Serial Key: %sWinProdKey%
echo\%hyphens%
echo\
call :choice yn "Would you like to save the information into a text file? Y/N: "
if errorlevel 2 goto exitwindowsactivation
if errorlevel 1 (
echo\
echo Processing...
set "ActivationFile=%StartDirApp%\%_OS% Activation Status.txt"
if exist "%ActivationFile%" del "%ActivationFile%"
echo %_OS% Activation Status... [%date% @ %time%]>>"%ActivationFile%"
echo\%hyphens%>>"%ActivationFile%"

for /f "tokens=*" %%a in ('call :getwindowsactivation') do (


echo Product ID: %ProductID%>>"%ActivationFile%"
echo Serial Key: %sWinProdKey%>>"%ActivationFile%"
echo\%hyphens%>>"%ActivationFile%" ) )
:exitwindowsactivation
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Windows activation menu status: Return to services menu]>>"%logdir%"
goto tools
::Display Windows Activation Status END

cscript //nologo "%_slmgr%" -dlv|findstr /i "Extended PID: ">>"%StartDirApp%\%_OS% Activation Status.txt"
cscript //nologo "%_slmgr%" -dli>>"%StartDirApp%\%_OS% Activation Status.txt"
cscript //nologo "%_slmgr%" -dlv|findstr /i "rearm count">>"%StartDirApp%\%_OS% Activation Status.txt"

::Change or Remove User Password START
:PCuserpassword
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: Loaded menu]>>"%logdir%"
call :PCUserPassword_Blocker
mode 52,18
echo -Password hack
call :header 17
echo\
echo       1. Remove %username%'s account password
echo       2. Set a password for %username%'s account
echo\
echo b/back
call :choice 12b "Make your selection: "
if errorlevel 3 (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: User backed out from change or remove user password menu]>>"%logdir%"
goto tools )
if errorlevel 2 goto usernamesetpassword
if errorlevel 1 goto usernameremovepassword


:usernameremovepassword
if "%PCuserpasswordflag%"=="true" goto PCuserpasswordnotavailable
echo\
call :choice yn "Remove %username%'s password? Y/N: "
if errorlevel 2 (
echo\
echo Cancelled - Returning to main menu...
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: User backed out from remove user password]>>"%logdir%"
goto PCuserpassword )
if errorlevel 1 (
echo\
echo Processing...
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: User requests to remove user password]>>"%logdir%"
net user %username% "" >nul
if "%errorlevel%"=="1" (goto usernameremovepasswordstatus0 ) else (goto usernameremovepasswordstatus1 )
:usernameremovepasswordstatus0
echo Done - Removing %username%'s password...
ping localhost -n 3 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: User removed user password]>>"%logdir%"
goto PCuserpassword 
:usernameremovepasswordstatus1
echo Error - Failed to remove %username%'s password...
ping localhost -n 3 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: Failed to remove user password]>>"%logdir%"
goto PCuserpassword )

:usernamesetpassword
if "%PCuserpasswordflag%"=="true" goto PCuserpasswordnotavailable
echo\
call :choice yn "Change %username%'s password? Y/N: "
if errorlevel 2 (
echo\
echo Cancelled - Returning to main menu...
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: User backed out from change user password]>>"%logdir%"
goto PCuserpassword )
if errorlevel 1 (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: User requests to change user password]>>"%logdir%"
goto usernamesetpasswordnow )
:usernamesetpasswordnow
echo Enter password:
set "userpassvar1="
if "%passcharmapmode%"=="Enabled" (
set "passcheck=%userpassvar1%"
set "456=%userpassvar1%"
set "hackpassword1=true"
call :replacepassChar )
if "%passcharmapmode%"=="Disabled" call :passHackCharnormal & goto passHackendhighend2
:passHackendhighend1
if "%passcheck%"=="" goto PCuserpassword
echo\
echo Confirm:
set "userpassvar2="
if "%passcharmapmode%"=="Enabled" (
set "passcheck=%userpassvar2%"
set "hackpassword2=true"
call :replacepassChar )

:passHackendhighend2
if "%passcheck%"=="" goto PCuserpassword
if "!userpassvar1!"=="!userpassvar2!" (
echo\
echo Processing...

echo "!456!" "%userHackpass2%"

net user %username% "%passcheck%" >nul
if "%errorlevel%"=="0" (goto usernamesetpasswordstatus0 ) else (goto usernamesetpasswordstatus1 )
:usernamesetpasswordstatus0
echo Done - Saved new password^^!
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: User set new user password]>>"%logdir%"
goto PCuserpassword
:usernamesetpasswordstatus1
echo Error - Failed to save new password^^!
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: Failed to set new user password]>>"%logdir%"
goto PCuserpassword
) else (
echo Error - Password did not match^^!
ping localhost -n 2 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: Password user input: entry incorrect]>>"%logdir%"
goto PCuserpassword )

:passHackCharnormal
set /p userpassvar1=
if "%userpassvar1%"=="" goto PCuserpassword
set "userpassvar2="
echo Confirm:
set /p userpassvar2=
exit /b

:PCuserpasswordnotavailable
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change or remove user password menu status: Feature blocked from specific user]>>"%logdir%"
echo\
echo Sorry this tool has been blocked from this computer
echo due to hacking. Contact the author if you have an
echo issue with this feature.
echo\
pause
cls
goto PCuserpassword
::Change or Remove User Password START


::Ping a website START
:pingwebsite
call :checkPingWebsiteOptionsReg
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Ping menu status: Loaded menu]>>"%logdir%"
set "pingURL="
set pingIPaddress=Not found
mode 52,13
echo -Ping
call :header 17
echo\
echo b/back o/options
echo Enter a website address to ping:
set /p pingURL=www.
if "%pingURL%"=="" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Ping website menu status: User entry is blank...]>>"%logdir%"
goto pingwebsite ) else if "%pingURL%"=="b" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Ping website menu status: User backed out from ping menu]>>"%logdir%"
goto tools )
if "%pingURL%"=="o" (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Ping website menu status: User requests ping website options menu...]>>"%logdir%"
cls
goto pingwebsiteoptions
) else (
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Ping website menu input website address: www.%pingURL%]>>"%logdir%" )
echo\
echo Processing...
echo\%pingURL%|findstr /rc:"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
if "%errorlevel%"=="0" (goto pingaddressprocess1 ) else (goto pingaddressprocessnext )
:pingaddressprocessnext
echo\%pingURL%|findstr /rc:"/" >nul
if "%errorlevel%"=="0" (goto pingaddressprocess1 ) else (goto pingaddressprocessnext2 )
:pingaddressprocessnext2
echo\%pingURL%|findstr /rc:"-" >nul
if "%errorlevel%"=="0" (goto pingaddressprocess1 ) else (goto pingaddressprocess )
:pingaddressprocess
::ping /n "%pinglayersnumber%" "%pingURL%" >nul
setLocal enableDelayedExpansion
set/a line=0
for /f "delims=" %%a in ('ping %pingURL%') do set/a line+=1
if "%errorlevel%"=="1" goto pingaddressprocess1
set "Line#[!line!]=%%a"
mode 80, 30
for /l %%a in (1 1 !line!) do echo !line#[%%a]!
pause
if "%pingwebsiteoutputmode%"=="Seperate" goto pingaddressprocessSeperate0
if "%pingwebsiteoutputmode%"=="Main" goto pingaddressprocessMain0


::do not remove spaces START
set LF=^





::do not remove spaces (Period END)

for /f "tokens=*" %%a in ('ping /n "%pinglayersnumber%" "%pingURL%"') do (
set "response=!response!%%a!LF!"
if "%errorlevel%"=="0" (
for /f "tokens=2delims=[]" %%i in ('ping /n "%pinglayersnumber%" "%pingURL%"^|find "["') do set "pingIPaddress=%%i"
if "%pingwebsiteoutputmode%"=="Seperate" goto pingaddressprocessSeperate0
if "%pingwebsiteoutputmode%"=="Main" goto pingaddressprocessMain0 )
if "%errorlevel%"=="1" goto pingaddressprocess1 )




:pingaddressprocessSeperate0
set /a "pingscreensize=13+%pinglayersnumber%"
start "" "CMD /c color %color% & mode 62,%pingscreensize% & call :title - Ping & echo\ & echo                      ---- Trinity ---- & echo !response! & ping localhost -n 2 >nul & echo\ & echo Connection exists... & ping localhost -n 7 >nul"
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Ping website menu status: IP Address: %pingIPaddress%]>>"%logdir%"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Ping website menu status: Address exists]>>"%logdir%"
ping localhost -n 2 >nul
cls
goto pingwebsite

:pingaddressprocessMain0
set /a "pingscreensize=13+%pinglayersnumber%"
mode 62,%pingscreensize%
echo\
call :header 21
echo\
::echo !response!
ping localhost -n 2 >nul
echo\
echo Connection exists...
ping localhost -n 7 >nul
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Ping website menu status: IP Address: %pingIPaddress%]>>"%logdir%"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Ping website menu status: Address exists]>>"%logdir%"
ping localhost -n 2 >nul
cls
goto pingwebsite

:pingaddressprocess1
echo Connection to host does not exist...
ping localhost -n 2 >nul
echo Try a different host^^!
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Ping website menu status: Address does not exist]>>"%logdir%"
goto pingwebsite


:pingwebsiteoptions
call :checkPingWebsiteOptionsReg
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Ping website options menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -Ping
call :header 17
echo\
echo               Current State: %pingwebsiteoutputmode%
echo\
echo          1. Show output in seperate window
echo          2. Show output in main window
echo\
echo b/back
call :choice 12b "Make your selection: "
if errorlevel 3 (
echo\
if "%savepingwebsiteflag%"=="true" (
echo Saved - Returning to ping website menu...
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Ping website options menu status: User saved ping website settings]>>"%logdir%"
) else (
echo Returning to ping website menu...
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Ping website options menu status: User ping website menu]>>"%logdir%" )
ping localhost -n 2 >nul
cls
goto pingwebsite )
if errorlevel 2 goto pingwebsitemain
if errorlevel 1 goto pingwebsiteseperate

:pingwebsiteseperate
call :checkPingWebsiteOptionsReg
if "%pingwebsiteoutputmode%"=="Seperate" goto pingwebsiteoptions
if "%pingwebsiteoutputmode%"=="Main"  (
set pingwebsiteoutputmode=Seperate
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Ping website options menu status: Ping website output changed to Seperate window]>>"%logdir%"
goto savepingwebsiteoptions )
:pingwebsitemain
call :checkPingWebsiteOptionsReg
if "%pingwebsiteoutputmode%"=="Main" goto pingwebsiteoptions
if "%pingwebsiteoutputmode%"=="Seperate" (
set pingwebsiteoutputmode=Main
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Ping website options menu status: Ping website output changed to Main window]>>"%logdir%"
goto savepingwebsiteoptions )

:savepingwebsiteoptions
set "savepingwebsiteflag=true"
>nul reg add "%RegKey%" /v "PING_OUTPUT" /t REG_SZ /d "%pingwebsiteoutputmode%" /f
goto pingwebsiteoptions
::Ping a website END

::Display Users On The Network START
:shownetworkusers
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Display network users menu status: Loaded menu]>>"%logdir%"
mode 52,26
echo -Network users
call :header 17
echo\
echo Listing Network Users...
echo\
net view >nul
for /f %%a in ('net view^| findstr/b \\') do @echo\%%a
echo\
echo Press any key to return...
pause >nul
cls
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Display network users menu status: Return to tools menu]>>"%logdir%"
goto tools
::Display Users On The Network END

::Plugin Manager START
:pluginmanger
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Display network users menu status: Loaded menu]>>"%logdir%"
mode 52,26
echo -Plugin manager
call :header 17
echo\
echo Listing plugins...
echo\
::code
echo 1. Download all
echo 2. Update all
echo
pause
 
::Plugin Manager START


::Show Program Information START
:infomenu
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Information menu status: Loaded menu]>>"%logdir%"
mode 52,13
echo -Info
call :header 17
echo\
echo                1. View disclaimer
echo                2. View change log
echo                3. Check for an update
echo                4. Visit our website
echo                5. About Trinity
echo                6. Introduction
echo\
echo b/back
call :choice 123456b "Make your selection: "
if "%errorlevel%"=="7" ( set "infomenuvar=Return main menu"
goto infomenuloginput )
if "%errorlevel%"=="6" ( set "infomenuvar=Introduction"
goto infomenuloginput )
if "%errorlevel%"=="5" ( set "infomenuvar=About Trinity"
goto infomenuloginput )
if "%errorlevel%"=="4" ( set "infomenuvar=Visit Trinity website"
goto infomenuloginput )
if "%errorlevel%"=="3" ( set "infomenuvar=Check for updates"
set "autoupdateflag=false"
goto infomenuloginput )
if "%errorlevel%"=="2" ( set "infomenuvar=View change log"
goto infomenuloginput )
if "%errorlevel%"=="1" ( set "infomenuvar=View disclaimer"
set "UIdisclaimer=false"
goto infomenuloginput )
:infomenuloginput
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Information menu user input status: %infomenuvar%]>>"%logdir%"
if "%errorlevel%"=="7" goto mainmenu
if "%errorlevel%"=="6" goto introduction
if "%errorlevel%"=="5" goto about
if "%errorlevel%"=="4" goto visitwebsite
if "%errorlevel%"=="3" goto checkupdate
if "%errorlevel%"=="2" goto changelog
if "%errorlevel%"=="1" goto disclaimer

:disclaimer
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Disclaimer menu status: Loaded menu]>>"%logdir%"
cls
mode 52,13
echo -Disclaimer
call :header 17
echo\
echo Do not edit/decompile or extract this program.
echo I am not responsible for any damage/loss of data.
echo HTTPS protocol may cause the program not to work.
echo It is strictly forbidden to sell this program
echo without permission of the author^^!
echo\
if "%DisclaimerUI%"=="Disabled" (
pause
cls
goto infomenu )
if "%DisclaimerUI%"=="Enabled" (
call :choice yn "I agree to the disclaimer? Y/N: "
if errorlevel 2 goto disclaimerN
if errorlevel 1 goto disclaimerY )

:disclaimerN
cls
echo\
echo D'oh^^!
echo\
echo Well that's to bad^^!
ping localhost -n 3 >nul
exit
:disclaimerY
set "DisclaimerUI=Disabled"
>nul reg add "%RegKey%" /v "DISCLAIMER_UI" /t REG_SZ /d "%DisclaimerUI%" /f
cls
exit /b

:changelog
if "%patameterflag%"=="false" if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Change log menu status: Loaded menu]>>"%logdir%"
set hyphencount=51
set "versionreleasedate=2013/09/30"
call :GetInternational
call :GetSecs "%versionreleasedate%" "00:00:00.00" startsec
call :GetSecs "%date%" "%time%" stopsec
set /a versionday=(%stopsec%-%startsec%)/86400
mode 52,20
echo -Change log
call :header 17
echo\
if "%versionday%"=="1" (echo Version: %version% [%versionreleasedate%, %versionday% day ago]
) else if "%versionday%" gtr "1" (echo Version: %version% [%versionreleasedate%, %versionday% days ago]
) else if "%versionday%"=="0" (echo Version: %version% [%versionreleasedate%, released today] )
set "hyphens="
for /l %%i in (1 1 %hyphencount%) do set "hyphens=!hyphens!-"
set "hyphens=%hyphens%"
echo\%hyphens%
echo *Added the ability to block websites.
echo *Added the ability to clear blocked websites.
echo *Added the ability to clear all blocked websites.
echo *Added the ability to redirect to a website.
echo *Added the ability to export blocked websites.
echo *Added the ability to import websites to block.
echo *Added the ability to display events in a log file.
echo *Added the ability to check if website valid.
echo *Added the ability to check internet connection.
echo *Added the ability to check program UAC rights.
echo *Added _hosts file security check.
echo *Added preferences and other tools.
echo\
pause
cls
if "%patameterflag%"=="true" exit
goto infomenu


::Check for updates START
:checkupdate
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Check for update menu status: Checking for an update]>>"%logdir%"
set "UpdateURL=http://trinity.bugs3.com/data/UpdateInfo.bat"
set "updateinfofile=%tempdir%\UpdateInfo.bat"
cls
mode 52,13
echo -Update
call :header 17
echo\
echo Checking for an update...
call :checkupdateinfoUAC
if exist "%updateinfofile%" del "%updateinfofile%"
set "errorlevel="
ping /n "%pinglayersnumber%" "%webhost%" >nul
if "%errorlevel%"=="0" (goto decideUpdateClient) else (call :updateinternetconnection1 )
:decideUpdateClient
call :PSdownClient
if not "%errorlevel%"=="8" (
call :checkfileUAC /l && if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" echo [%time%] [Check for update menu status: Using Powershell to check for an update]>>"%logdir%"
goto usePSUpdateClient )
call :WGETdownClient
if "%errorlevel%"=="2" (
call :noDownloadClient &goto UpdateErrorMsg ) else (
call :checkfileUAC /l && if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" echo [%time%] [Check for update menu status: Using wget.exe to check for an update]>>"%logdir%"
goto useWgetUpdateClient )

:usePSUpdateClient
set "PSClientURL=%UpdateURL%"
set "PSClientLocalFile=%updateinfofile%"
call :PSdownClient
if "%errorlevel%"=="0" (goto getupdateinfo1
) else if "%errorlevel%" gtr "0" (goto checkupdateinfofile )
:useWgetUpdateClient
set "WGETClientURL=%UpdateURL%"
set "WGETClientLocalFile=%updateinfofile%"
call :WGETdownClient
if "%errorlevel%"=="0" (goto checkupdateinfofile ) else (goto getupdateinfo1 )

:checkupdateinfofile
findstr /i "TRINITY_UPDATEINFO_FILE" "%updateinfofile%" >nul 2>nul
if "%errorlevel%"=="0" (goto getupdateinfo0 ) else (
:getupdateinfo1
call :checkupdateinfoUAC
if exist "%updateinfofile%" del "%updateinfofile%"
echo\
echo Error - Failed to retrieve update information...
ping localhost -n 3 >nul
cls
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Check for update menu status: Failed to retrieve update information from web server]>>"%logdir%"
if "%autoupdateflag%"=="false" goto infomenu
if "%autoupdateflag%"=="true" goto mainmenu )
:getupdateinfo0
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Check for update menu status: Calculating update information]>>"%logdir%"
call :checkupdateinfoUAC
if exist "%updateinfofile%" call "%updateinfofile%"
if exist "%updateinfofile%" del "%updateinfofile%"
set checkupdate=true
if "%version%"=="%currentversion%" (call :updateFalse &goto UpdateErrorMsg ) else (goto updateTrue )
goto getupdateinfo1

:updateTrue
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Check for update menu status: Update is availabe]>>"%logdir%"
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Check for update menu status: Found new update version: %currentversion%]>>"%logdir%"
set "updatefixes=%updatefixes:""=!LF!%"
set "versionreleasedate=%updatedate%"
call :GetInternational
call :GetSecs "%versionreleasedate%" "00:00:00.00" startsec
call :GetSecs "%date%" "%time%" stopsec
set /a versionday=(%stopsec%-%startsec%)/86400
mode %updatemodesize%
set "spaces="
for /l %%i in (1 1 %titlespacecount%) do set "spaces=!spaces! "
cls
echo -True
echo\%spaces%---- Trinity ----
echo\
echo There is an update available for Trinity...
echo The details for the update are as follows:
echo\
if "%versionday%"=="1" (echo Latest version: %currentversion% [%versionreleasedate%, %versionday% day ago]
) else if "%versionday%" gtr "1" (echo Latest version: %currentversion% [%versionreleasedate%, %versionday% days ago]
) else if "%versionday%"=="0" (echo Latest version: %currentversion% [%versionreleasedate%, released today] )
echo Current version: %version%
set "hyphens="
for /l %%i in (1 1 %borderhyphencount%) do set "hyphens=!hyphens!-"
set "hyphens=%hyphens%"
echo\%hyphens%
echo\!updatefixes!
if "%updatemsg%"=="" (echo\ ) else (
echo\
echo\!updatemsg!
echo\)
echo Update your version of Trinity?
call :choice yn "Download it? (%downloadtype%) Y/N: "
if errorlevel 2 (
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Check for update menu status: User backed out from downloading update]>>"%logdir%"
if "%autoupdateflag%"=="false" goto infomenu
if "%autoupdateflag%"=="true" goto mainmenu )
if errorlevel 1 goto downloadupdatefile
:downloadupdatefile
if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [Check for update menu status: User requests to download update]>>"%logdir%"
echo\
echo Downloading...
ping /n "%pinglayersnumber%" "%webhost%" >nul
if "%errorlevel%"=="0" (goto decideDownloadProtocol ) else (call :updateinternetconnection1 &goto UpdateErrorMsg )

:decideDownloadProtocol
set "newversionupdatefile=%StartDirApp%Trinity v%currentversion%.bat"
if exist "%newversionupdatefile%" del "%newversionupdatefile%"
if not "%updatefileURL%"=="" (
if "%downloadtype%"=="ftp" goto downloadupdatefileFTP
if "%downloadtype%"=="http" goto downloadupdatefileHTTP
if "%downloadtype%"=="link" goto downloadupdatefilLINK
) else (call :noUpdateDownloadLink0 &goto UpdateErrorMsg )

:downloadupdatefileFTP
REM No need for the other variables because the update file has the same variables
set "FTPClientURL=%updatefileURL%"
set "FTPClientRemoteFile=%updatefilename%"
set "FTPClientLocalFile=%newversionupdatefile%"
call :FTPdownClient
if "%errorlevel%"=="0" (goto searchupdatefile ) else (goto downloadupdate1 )

:downloadupdatefileHTTP
call :PSdownClient
if not "%errorlevel%"=="8" (
call :checkfileUAC /l && if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" echo [%time%] [Check for update menu status: Using Powershell to download the update]>>"%logdir%"
goto usePSClientDownUpdate )
call :WGETdownClient
if "%errorlevel%"=="2" (
call :noDownloadClient &goto UpdateErrorMsg ) else (
call :checkfileUAC /l && if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" echo [%time%] [Check for update menu status: Using wget.exe to download the update]>>"%logdir%"
goto useWgetClientDownUpdate )

:usePSClientDownUpdate
set "PSClientURL=%updatefileURL%"
set "PSClientLocalFile=%newversionupdatefile%"
call :PSdownClient
if "%errorlevel%"=="0" (goto downloadupdate1
) else if "%errorlevel%" gtr "0" (goto searchupdatefile )
:useWgetClientDownUpdate
set "WGETClientURL=%updatefileURL%"
set "WGETClientLocalFile=%newversionupdatefile%"
call :WGETdownClient
if "%errorlevel%"=="0" (goto searchupdatefile ) else (goto downloadupdate1 )

:downloadupdatefilLINK
start %updatefileURL%
if "%errorlevel%"=="0" (
echo Done - Started Trinity update link to browser...
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Check for update menu status: Started Trinity update link to browser]>>"%logdir%"
cls ) else (
echo Error - Failed to start Trinity update link...
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Check for update menu status: Failed to start available update link]>>"%logdir%"
cls )
if "%autoupdateflag%"=="false" goto infomenu
if "%autoupdateflag%"=="true" goto mainmenu


:searchupdatefile
call :checkupdatedfileUAC
findstr /i /c:"TRINITY_OFFICIAL_BATCH_FILE" "%newversionupdatefile%" >nul
if "%errorlevel%"=="0" (
echo Done - Downloaded Trinity update...
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Check for update menu status: Downloaded available update]>>"%logdir%"
cls ) else (
:downloadupdate1
call :checkupdatedfileUAC
if exist "%newversionupdatefile%" del "%newversionupdatefile%"
echo Error - Failed to download Trinity update...
ping localhost -n 3 >nul
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Check for update menu status: Failed to downloaded available update]>>"%logdir%"
cls )
if "%autoupdateflag%"=="false" goto infomenu
if "%autoupdateflag%"=="true" goto mainmenu

::Updater Error Messages
:updateFalse
set "UpdateErrorTitleMsg=False"
set "UpdateErrorMsg1=Your version of Trinity is up to date..."
set "UpdateErrorMsg2=Current version: %version%"
set "UpdateErrorLog1Msg=Check for update menu status: No update available"
set "UpdateErrorLog2Msg=Check for update menu status: User returned to menu"
set "UpdateFailMsg="& set "updateFalseVar=True"& set "updateDetailedLogVar=True"
goto UpdateErrorMsg
:updateinternetconnection1
set "UpdateErrorTitleMsg=Disconnected"
set "UpdateErrorMsg1=Failed to check for Trinity update."
set "UpdateErrorMsg2=Please reconnect your ethernet cable."
set "UpdateErrorLog1Msg=Check for update menu status: Failed to get update information"
set "UpdateErrorLog2Msg=Internet connection current state: Disconnected"
set "UpdateFailMsg=Your computer is not connected to the internet..."& set "updateFalseVar=False"& set "updateDetailedLogVar=False"
goto UpdateErrorMsg
:noDownloadClient
set "UpdateErrorTitleMsg=No Client"
set "UpdateErrorMsg1=Failed to find powershell installed."
set "UpdateErrorMsg2=Tried to find wget.exe in the root directory."
set "UpdateErrorLog1Msg=Check for update menu status: Failed to find upate client"
set "UpdateErrorLog2Msg=Check for update menu status: User returned to menu"
set "UpdateFailMsg=Sorry, you can't download the update..."& set "updateFalseVar=False"& set "updateDetailedLogVar=True"
goto UpdateErrorMsg
:noUpdateDownloadLink0
set "UpdateErrorTitleMsg=Update Link"
set "UpdateErrorMsg1=Failed to dowload update"
set "UpdateErrorMsg2=The link for the update seems to be blank."
set "UpdateErrorLog1Msg=Check for update menu status: Failed to download upate"
set "UpdateErrorLog2Msg=Check for update menu status: Update URL is blank"
set "UpdateFailMsg="& set "updateFalseVar=False"& set "updateDetailedLogVar=False"
goto UpdateErrorMsg

:UpdateErrorMsg
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [%UpdateErrorLog1Msg%]>>"%logdir%"
mode 52,13
echo -%UpdateErrorTitleMsg%
call :header 17
echo\
if not "%UpdateFailMsg%"=="" (echo\%UpdateFailMsg%
echo\)
echo\%UpdateErrorMsg1%
echo\%UpdateErrorMsg2%
echo\
pause
cls
if "%updateDetailedLogVar%"=="True" (if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [%UpdateErrorLog2Msg%]>>"%logdir%"
) else if "%updateDetailedLogVar%"=="False" (if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [%UpdateErrorLog2Msg%]>>"%logdir%" )
if "%autoupdateflag%"=="false" (
if "%updateFalseVar%"=="True" (if "%logmode%"=="Enabled" if "%logtype%"=="Detailed" call :checkfileUAC /l && echo [%time%] [%UpdateErrorLog2Msg%]>>"%logdir%" )
goto infomenu )
if "%autoupdateflag%"=="true" goto mainmenu
::Check for updates END


:visitwebsite
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Visit Trinity website menu status: Loaded menu]>>"%logdir%"
cls
mode 52,13
echo -Visit website
call :header 17
echo\
echo Starting Trinity website link...
ping localhost -n 2 >nul
start http://trinity.bugs3.com/
cls
goto infomenu


:about
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [About Trinity menu status: Loaded menu]>>"%logdir%"
cls
mode 52,19
echo -About
call :header 17
echo\
echo Trinity - The 3-in-1 file manager
echo\
echo Coded By: Adrian van den Houten
echo\
echo Current version: %version%
if "%checkupdate%"=="true" echo Latest version: %currentversion%
echo Lanaguge: English
echo\
echo License: Freeware
echo\
echo This software may only be free of charge^!
echo For more read the change log or visit the website.
echo\
pause
cls
goto infomenu

:introduction
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Disclaimer menu status: Loaded menu]>>"%logdir%"
cls
mode 52,13
echo -Introduction
call :header 17
echo Page 1/2
echo Welcome to Trinity...



echo Trinity is free and open source DOS-Based script.
echo This program includes the ability to block websites
echo redirect website's or local server, import a list
echo of websites you wish to manage or export to a list.
echo Users appreciate just how configurable it is.
echo Other tools are included.
echo\
echo For more read the change log or visit the website.
::Show Program Information END

:parameter
echo Trinity version %version%
echo\
echo Usage: trinity [mode] [/admin] [/p password] [/C] [/n ip host] [/r host] [/a]
echo\       [/ex file] [/im file] [/f string] [/c count [/s]] [/t lines] [/r] [/?]
echo\
echo Mode: required argument specifing which file to write to.
echo\
echo\   /hosts         Mapping IP addresses to host names.
echo\   /imhosts       Mappings of IP addresses to computernames (NetBIOS) names.
echo\   /networks      Network name/network number mappings for local networks.
echo\
echo Options:
echo\
echo\   /admin        Run trinity with administrator privileges.
echo\                 Required to write to editor file.
echo\                 Show Windows activation status.
echo\   /p password   Specify the program password for access.
echo\   /C            Check the editor file for any syntax errors.
echo\                 Discard duplicates.
echo\   /n ip host    Add new entry to editor file.
echo\   /r host       Remove a entry from editor file.
echo\   /a            Remove all entries from editor file. 
echo\   /ex file      Export the editor file to save file location.
echo\   /im file      Overwrite (import) the editor file to file location.
echo\   /f string     Find an item in editor file.
echo\   /c            Count the number of lines of editor file.
echo\   /s            Used with /c to ignore comment lines.
echo\   /t count      Number of lines to skip for writing new entry.
echo\   /?            Display this help and version.
echo\
goto :EOF

:notsupported
mode 52,16
echo -Not supported
call :header 17
echo\
echo Running: %_OS%
echo\
echo Error - Only supported on...
echo - Microsoft Windows 8.1
echo - Microsoft Windows 8
echo - Microsoft Windows 7
echo - Microsoft Windows Vista
echo - Microsoft Windows XP
echo\
echo NOTE: x86 and x64 are both supported.
echo\
pause
goto exit

:banned
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Banned menu status: User has been banned^^!]>>"%logdir%"
set count=3
mode 55,13
echo -Banned
call :header 17
echo\
echo Hello %username%...
echo You are banned from this program, reason may differ.
echo Please consult with the author for a security key.
echo\
pause
goto register



REM Checks the write permission of passed file
:writePermission "input" "reason" ex
setlocal
  set "input=%~1"
  set "reason=%~2"
for /F %%a in ('^(^(set "X=" ^< nul^)^>^>"!input!"^)2^>^&1') do (

  REM If permission denied
  call :writePermissionMsg
)
endlocal
set "%~3=%errorlevel%"
exit /b

:writePermissionMsg
cls
mode 61,16
color c
echo Access denied:
echo "%input%"
echo\
echo Error Discription: %reason%
echo\
echo ...Advice... (at your own risk)
echo 1) Click start button
echo 2) Type UAC into seach text box
echo 3) Click Change User Account Control settings applet
echo 4) Change mode to "Never notify me when"
echo 5) Restart your computer
echo 6) Run Trinity
echo\
echo Press any key to exit...
pause >nul
exit


::Log file function START
:writeLogFile "text" ex
call :writePermission "%_logfileDir%" "Writing log to file" ex
setlocal
  set "text=%~1"
  if "%log_mode%"=="0" ( echo [%time%] [%text%]>>"%_logfileDir%" )
endlocal
set "%~2=%errorlevel%"
exit /b
REM Usage:
:: Argument "0" (General) used for 'General" log message information
:: Argument "1" (Detailed) used for 'Detailed" log message information
:: call :writeLogFile 0 "This is the text for the log file"
REM Exception:
:: If the argument '0' or '1' is not supplied then it will treat it as '0'
:: If the text message argument '"Message"' is not supplied then it will display the message:
:: "Log text message argument is blank"
REM
::Log file function END

:checkFileDialogSwitch
if %file_dialog%==0 (
  exit /b
) else if %file_dialog%==1 (
  exit /b
)
set file_dialog=0
exit /b

:checkChoiceFuncSwitch
if %choice_func%==0 (
  exit /b
) else if %choice_func%==1 (
  exit /b
)
set choice_func=1
exit /b

:checkLogModeSwitch
if %log_mode%==0 (
  exit /b
) else if %log_mode%==1 (
  exit /b
)
set log_mode=0
exit /b

:checkAutoUpdateSwitch
if %check_update%==0 (
  exit /b
) else if %check_update%==1 (
  exit /b
)
set check_update=1
exit /b

:checkProcBarSwitch
if %process_bar%==0 (
  exit /b
) else if %process_bar%==1 (
  exit /b
)
set process_bar=1
exit /b

:checkcalcDurationSwitch
if %calc_duration%==0 (
  exit /b
) else if %calc_duration%==1 (
  exit /b
)
set calc_duration=0
exit /b

:checkPingOutputSwitch
if %ping_output%==0 (
  exit /b
) else if %ping_output%==1 (
  exit /b
)
set ping_output=0
exit /b

:checkPingRequestsSwitch
call :numeric_range "2" "1" "10" "%ping_requests%"

:checkHeightSwitch
call :numeric_range "42" "30" "80" "%program_height%"


REM Corrects numbers that are out of range of "min" "max"
REM Corrects non-integers to "default" value
:numeric_range "default" "min" "max" "value"
setlocal
set default=%~1
set min=%~2
set max=%~3
set value=%~3

set /a "numeric=%value%" 2>nul && (

  if "!numeric!"=="!value!" (
  
    if !numeric! geq %min% (

      if !numeric! leq %max% (
        exit /b
      ) else (
        set value=%default%
      )
	  
    ) else (
      set value=%default%
    )
	
  ) else (
    set value=%default%
  )
  
) || (
  set value=%default%
)
endlocal
exit /b
::END


REM Read data and assign a variable
:reqQuery "keyName" "options" "valueName" returnValue ex
set "value="
REM Option Parameters:
set "_v="
setlocal
  set "keyName=%~1"
  set "options=%~2"
  set "valueName=%~3"
  
  for %%a in (%options%) do (
  
    if "%%~a"=="/v" (
      set "_v=true"
    )
  )
  
  if defined _v (
    REM Get value and store in %value%
	reg query "%keyName%" /v "%valueName%" >nul 2>nul
	
	if %errorlevel%==1 (
      for /f "tokens=2*" %%i in ('reg query "%keyName%" /v "%valueName%"') do set "value=%%j" >nul 2>nul
	)
  ) else (
    REM Check if key name exists
    reg query "%keyName%" >nul 2>nul
  )
endlocal &set "_v=%_v%" &set "value=%value%"
REM Returned data to user
if defined _v (
  set "%~4=%value%"
  set "%~5=%errorlevel%"
) else (
  set "%~2=%errorlevel%"
)
exit /b
::END
REM call :reqQuery "%_defaultKey%" "/v" "LOG_MODE" item ex

::Insert new data
:regInsert "keyName" "options" "valueName" "value" ex
REM Option Parameters:
set "_v="
setlocal
  set "keyName=%~1"
  set "options=%~2"
  set "valueName=%~2"
  set "value=%~3"
  
  for %%a in (%options%) do (
    if "%%~a"=="/v" (
      set "_v=true"
    )
  )
  
  if defined _v (
    >nul reg add "%keyName%" /v "%valueName%" /t REG_SZ /d "%value%" /f >nul 2>nul
  ) else (
    >nul reg add "%keyName%" /ve >nul 2>nul
  )
endlocal &set "_v=%_v%"
REM Returned data to user
if defined _v (
  set "%~5=%errorlevel%"
) else (
  set "%~2=%errorlevel%"
)
exit /b
::END
REM call :regInsert "%_defaultKey%" "/v" "LOG_MODE" NewData ex

:: change existing data (same as adding new)
:regUpdate "keyName" "valueName" "value" ex
setlocal
  set "keyName=%~1"
  set "valueName=%~2"
  set "value=%~3"
  
  >nul reg add "%keyName%" /v "%valueName%" /t REG_SZ /d "%value%" /f >nul 2>nul
  ::check
  for /f "tokens=2*" %%i in ('reg query "%keyName%" /v "%valueName%"') do set "ex=%%j" >nul 2>nul
  
endlocal
set "%~4=%ex%"
exit /b
::END
REM call :regUpdate "%_defaultKey%" "LOG_MODE" "Herro" ex

:: delete a certain value
:regDelete "keyName" "valueName" ex
setlocal
  set "keyName=%~1"
  set "valueName=%~2"
  >nul reg delete "%keyName%" /v "%valueName%" /f >nul 2>nul
  :: check (error if the deletion was successful)
  reg query "%keyName%" /v "%valueName%"  >nul 2>nul
endlocal
set "%~3=%errorlevel%"
exit /b
::END
REM call :regDelete "%_defaultKey%" "LOG_MODE" ex



REM Save and default program settings START
:checkDirectModeReg
reg query "%RegKey%" /v "DIRECT_MODE" >nul 2>nul
if "!errorlevel!"=="0" for /f "tokens=2*" %%i in ('reg query "%RegKey%" /v "DIRECT_MODE"') do set "directmode=%%j"
call :Defaultlogtype
>nul reg add "%RegKey%" /v "DIRECT_MODE" /t REG_SZ /d "%directmode%" /f
exit /b

:checkDirectStateReg
reg query "%RegKey%" /v "DIRECT_STATE" >nul 2>nul
if "!errorlevel!"=="0" for /f "tokens=2*" %%i in ('reg query "%RegKey%" /v "DIRECT_STATE"') do set "directstate=%%j"
if "%directstate%"=="uilocalhost" exit /b
if "%directstate%"=="uiwebsite" exit /b
if "%directstate%"=="uiIPaddess" exit /b
call :Defaultlogtype
>nul reg add "%RegKey%" /v "DIRECT_STATE" /t REG_SZ /d "%directstate%" /f
exit /b

:checkIPAddressReg
reg query "%RegKey%" /v "IP_ADDRESS" >nul 2>nul
if "!errorlevel!"=="0" for /f "tokens=2*" %%i in ('reg query "%RegKey%" /v "IP_ADDRESS"') do set "IPaddress=%%j"
if "%IPaddress%"=="127.0.0.1" exit /b
::if "%IPaddress%"=="%redirectIP%" exit /b
call :Defaultlogtype
>nul reg add "%RegKey%" /v "IP_ADDRESS" /t REG_SZ /d "%IPaddress%" /f
exit /b




:checkPassModeReg
set "/d="&set "/r="
for %%a in (%*) do (
  if "%%~a"=="/d" ( set "/d=true"
   ) else if "%%~a"=="/r" set "/r=true"
)
if defined /d set passwordmode=Disabled
if defined /r (
reg query "%RegKey%" /v "PASS_MODE" >nul 2>nul
if "!errorlevel!"=="0" for /f "tokens=2*" %%i in ('reg query "%RegKey%" /v "PASS_MODE"') do set "passwordmode=%%j"
if "%passwordmode%"=="Enabled" (exit /b
) else if "%passwordmode%"=="Disabled" (exit /b
) else ( >nul reg delete "%RegKey%" /v "PASS_MODE" /f )
call :checkcalcDurationReg /d
>nul reg add "%RegKey%" /v "PASS_MODE" /t REG_SZ /d "%passwordmode%" /f )
exit /b


:checkPassCountReg

exit /b



:disclaimerUIcheck
if "%DisclaimerUI%"=="Enabled" call :disclaimer
exit /b

:checkDisclaimerUIReg
ping localhost -n 2 >nul
set "/d="&set "/r="
for %%a in (%*) do (
  if "%%~a"=="/d" ( set "/d=true"
   ) else if "%%~a"=="/r" set "/r=true"
)
if defined /d set DisclaimerUI=Enabled
if defined /r (
reg query "%RegKey%" /v "DISCLAIMER_UI" >nul 2>nul
if "!errorlevel!"=="0" for /f "tokens=2*" %%i in ('reg query "%RegKey%" /v "DISCLAIMER_UI"') do set "DisclaimerUI=%%j"
if "%DisclaimerUI%"=="Enabled" (exit /b
) else if "%DisclaimerUI%"=="Disabled" (exit /b
) else ( >nul reg delete "%RegKey%" /v "DISCLAIMER_UI" /f )
call :checkDisclaimerUIReg /d
>nul reg add "%RegKey%" /v "DISCLAIMER_UI" /t REG_SZ /d "%DisclaimerUI%" /f )
exit /b
REM Save and default program settings END



REM Command Arguments Functions START
:RestoreReg
echo Restoring Trinity registry items to default...
echo\
reg delete "%RegKey%" /f >nul 2>nul
call :Defaultlogtype
>nul reg add "%RegKey%" /v "DIRECT_MODE" /t REG_SZ /d "%directmode%" /f &call :Defaultlogtype
>nul reg add "%RegKey%" /v "DIRECT_STATE" /t REG_SZ /d "%directstate%" /f &call :Defaultlogtype
>nul reg add "%RegKey%" /v "IP_ADDRESS" /t REG_SZ /d "%IPaddress%" /f &call :Defaultlogmode
>nul reg add "%RegKey%" /v "LOG_MODE" /t REG_SZ /d "%logmode%" /f &call :Defaultlogtype
>nul reg add "%RegKey%" /v "LOG_TYPE" /t REG_SZ /d "%logtype%" /f &call :Defaultcharmap
>nul reg add "%RegKey%" /v "CHARACTER_MAP" /t REG_SZ /d "%passcharmapmode%" /f &call :Defaultpinglayer
>nul reg add "%RegKey%" /v "PING_PLAYERS" /t REG_SZ /d "%pinglayersnumber%" /f &call :Defaultheightsize
>nul reg add "%RegKey%" /v "HEIGHT_SIZE" /t REG_SZ /d "%heightsizemode%" /f &call :Defaultautoupdatemode
>nul reg add "%RegKey%" /v "AUTO_UPDATE" /t REG_SZ /d "%autoupdatemode%" /f &call :DefaultpingWOmode
>nul reg add "%RegKey%" /v "PING_OUTPUT" /t REG_SZ /d "%pingwebsiteoutputmode%" /f
if "%errorlevel%"=="0" (echo Operation successfully completed^^!
) else (
echo Error - Failed to restore Trinity regisrty items to default...
echo\
echo Please try again later. )
goto :EOF
REM Command Arguments Functions END




REM Get System Version
:sysVerion "CurrentVersion" "CurrentBuild" "OS" "cpuArch"
call :reqQuery "HKLM\Software\Microsoft\Windows NT\CurrentVersion" "/v" "CurrentVersion" CurrentVersion ex
call :reqQuery "HKLM\Software\Microsoft\Windows NT\CurrentVersion" "/v" "CurrentVersion" CurrentBuild ex

if %ex%==0 (
  if "%CurrentVersion%"=="5.1" (
    set _OS=Windows Xp
  ) else if "%CurrentVersion%"=="6.0" (
    set _OS=Windows Vista
  ) else if "%CurrentVersion%"=="6.1" (
    set _OS=Windows 7
  ) else if "%CurrentVersion%"=="6.2" (
    set _OS=Windows 8
  ) else if "%CurrentVersion%"=="6.3" (
    set _OS=Windows 8.1
  )
  
) else if "%_OS%"=="Unknown" (
  goto notsupported
)

if %processor_architecture%==AMD64 set _CPU=x64
if %processor_architecture%==x86 set CPU=x86

set "%~1=%CurrentVersion%"
set "%~2=%CurrentBuild%"
set "%~3=%_OS%"
set "%~4=%_CPU%"
exit /b
::END


:procbar "percent"
setlocal
set percent=%~1
set length=40

set /a cblocks=%length%/100*40
echo %cblocks%
pause

for /l %%i in (1 1 %cblocks%) do set "dblocks=!dblocks!="

set /a cspaces=(%length%-%cblocks%)-1
echo %cspaces%

for /l %%i in (1 1 %cspaces%) do set "dspaces=!dspaces! "

echo [%dblocks%^>%dspaces%] %percent%%%
endlocal
exit /b



:header
set "spaces="
for /l %%i in (1 1 %~1) do set "spaces=!spaces! "
echo\%spaces%---- Trinity ----
exit /b

:title
title Trinity
exit /b

:exit
if "%logmode%"=="Enabled" call :checkfileUAC /l && echo [%time%] [Exit Trinity Version %version%] [Thank you for choosing Trinity]>>"%logdir%"
exit


REM Functions START :: Developed @ http://www.dostips.com/
REM Plugin System START
:initiatePlugin
set "PluginFunctions.length=3"
set "PluginFunctions[Pluginable1]=2"
set "PluginFunctions[Pluginable2]=3"
set "PluginFunctions[Pluginable3]=1"
set "PluginFunctions[1]=call :Pluginable3"
set "PluginFunctions[2]=call :Pluginable1"
set "PluginFunctions[3]=call :Pluginable2"
set "usePlugins=true"
goto :processParams

:processParams
if /I .%1 == ./noPlugins set "usePlugins=false"
goto :pluginManager

:pluginManager
if %usePlugins% == false goto :main
for %%f in (plugins\*.bat) do (
   set "header="
   (set /P "header=" < %%f)
   for /F "tokens=1-3" %%r in ("!header!") do (
      if .%%r%%s == .@remMY_BATCH_FILE_NAME_TEXT (
         set "PluginFunction=%%~t"
         set "PluggedInFunction=%%~f"

         for /F %%p in ("!PluginFunction::=!") do (
            set "PluginFunctions[!PluginFunctions[%%~p]!]=call "!PluggedInFunction!""
         )
      )
   )
)
goto :main

:callfunction
set "params=%*"
set "command=%1"
for /F %%c in ("!PluginFunctions[%command::=%]!") do set "command=!PluginFunctions[%%~c]!"
%command% %params:* =%
exit /b %errorlevel%
REM Plugin System END


::Powershell Download Client START
:PSdownClient "PSClientURL" "PSClientLocalFile" ex
setlocal
  set "PSClientURL=%~1"
  set "PSClientLocalFile=%~2"

for %%i in (powershell.exe) do if "%%~$path:i"=="" (

  REM PowerShell exe not found
  set "errorlevel=8" &exit /b
  
) else ( 

  set "ps="
  set "ps=%ps%try {"
  set "ps=%ps%  $filename = \"!PSClientLocalFile!\";"
  set "ps=%ps%  $url = \"!PSClientURL!\";"
  set "ps=%ps%  $client = new-object System.Net.WebClient;"
  set "ps=%ps%  $client.DownloadFile($url, $filename);"
  set "ps=%ps%  Exit 1"
  set "ps=%ps%}"
  set "ps=%ps%catch [System.Net.WebException] {"
  set "ps=%ps%  Exit 2"
  set "ps=%ps%}"
  set "ps=%ps%catch [System.IO.IOException] {"
  set "ps=%ps%  Exit 3"
  set "ps=%ps%}"
  set "ps=%ps%catch {"
  set "ps=%ps%  Exit 4"
  set "ps=%ps%}"
  set "ps=%ps%Exit 0"
  powershell Set-ExecutionPolicy Unrestricted
  powershell -ExecutionPolicy RemoteSigned -Command "%ps%"  >nul 2>nul
)

endlocal
set "%~3=%errorlevel%"
call :title &exit /b
REM Usage:
:: call :PSdownClient "http://yourdomain.com/file.ext" "C:\file.ext" ex 
REM Exception:
:: if "%errorlevel%"=="0" (goto failed
:: ) else if "%errorlevel%"=="8" (goto noPSinstalled
:: ) else if "%errorlevel%" gtr "0" (goto success )
REM
::Powershell Download Client END



::WGET Download Client START
:WGETdownClient "WGETClientURL" "WGETClientLocalFile" ex
setlocal
  set "WGETClientURL=%~1"
  set "WGETClientLocalFile=%~2"

REM Check start up directory for wget.exe
for %%i in (wget.exe) do if "%%~$_startDir:i"=="" (

  REM Couldn't find wget.exe in start up directory
  REM Check system path directory for wget.exe
  for %%i in (wget.exe) do if "%%~$path:i"=="" (
  
    REM Couldn't find wget.exe system path directory
    set "errorlevel=2"
	
  ) else (
     REM Fond wget.exe system path directory
     set "wgetDir=%path%"
   )
) else (
REM Found wget.exe in start up directory
set "wgetDir=%_startDir%"
)

  REM Change dir to wget.exe location
  cd "%wgetDir%" >nul 2>nul
  REM Use wget.exe to download
  wget.exe -q -O "%WGETClientLocalFile%" "%WGETClientURL%" >nul 2>nul
  
endlocal
set "%~3=%errorlevel%"
exit /b
REM Usage:
:: call :WGETdownClient "http://yourdomain.com/file.ext" "C:\file.ext" ex 
:: Use argument "/q" for no output
REM Exception:
:: if "%errorlevel%"=="0" (goto success ) else (goto failed
:: ) else if "%errorlevel%"=="2" (goto noWGET)
REM
::WGET Download Client END


::FTP Download Client START
:FTPdownClient "FTPServer" "user" "password" "cdDir" "FTPServerRemoteFile" "FTPClientLocalFile" ex
setlocal
  set "FTPServer=%~1"
  set "user=%~2"
  set "password=%~3"
  set "cdDir=%~4"
  set "FTPServerRemoteFile=%~5"
  set "FTPClientLocalFile=%~6"
  
for /f "delims=" %%i in (
  '^(^(^
    echo verbose on^&^
    echo open %FTPServer%^&^
    echo user %FTPUser% %FTPPass%^&^
	echo cd "%cdFTPdir%"^&^
	echo binary^&^
    echo get "%FTPServerRemoteFile%" "%FTPClientLocalFile%"^&^
    echo disconnect^&^
    echo bye^
  ^)^|ftp -n -d^) 2^>^&1 ^|findstr /ic:"Can't open"'
) do echo "%%i" >nul

endlocal
set "%~7=%errorlevel%"
exit /b
REM Usage:
:: call :FTPdownClient "ftp.ubuntu.com" "anonymous" "" "project/trace" "atemoya.canonical.com" "C:\atemoya.com" ex
REM Exception:
:: if "%errorlevel%"=="0" (goto success ) else (goto failed )
REM
::FTP Download Client END


REM call :fileDialog "open" "hosts file" "*" "hf"
::File Dialogue START
:fileDialog "dialogMode" "fileDesc" "fileExt" ex
setlocal
  set "dialogMode=%~1"
  set "fileDesc=%~2"
  set "fileExt=%~3"

for %%i in (powershell.exe) do if "%%~$path:i"=="" (

  REM powershell.exe not found
  call :uiFileDialog
  
) else (

  REM Start new thread to check "file_dialog" value is valid, if not default loaded
  start /b "" "%~f0" launch checkFileDialogSwitch
  
  if %file_dialog%==0 (
  
    if %dialogMode%==open set PSfileMode=OpenFileDialog
    if %dialogMode%==open set PSfileMode=SaveFileDialog
    call :PSfileDialog
	
  ) else if %FileDialog%==1 (
  
    call :uiFileDialog
  )
  
)
exit /b

:PSfileDialog
set "FileName="
  
  REM Build on CLI PowerShell Dialog
  set "ps=Add-Type -AssemblyName System.windows.forms | Out-Null;"
  set "ps=%ps% $f=New-Object System.Windows.Forms.%PSfileMode%;"
  set "ps=%ps% $f.Filter='%fileDesc% (*.%fileExt%)|.%fileExt%';"
  set "ps=%ps% $f.showHelp=$true;"
  set "ps=%ps% $f.ShowDialog() | Out-Null;"
  set "ps=%ps% $f.FileName"
  
  REM  Something
  for /f "delims=" %%i in ('powershell "%ps%"') do set "FileName=%%i"
  
  REM <Re-look at>
  if defined FileName set "errorlevel=2"
  if not defined FileName set "errorlevel=3"
  if "%FileName%"=="" set "errorlevel=3"
  
exit /b
set %~4=%errorlevel%

:uiFileDialog
if "%AddressMode%"=="File" (
echo Please enter the file address:
set /p FileName=



) else if "%AddressMode%"=="Dir" (
echo Please enter the directory address: 
set /p FileName=


)
endlocal
exit /b
REM Usage:
:: Argument "Im" (Import) used for open dialogue
:: Argument "Ex" (Export) used for save as dialogue
:: Argument "File" is a file dialogue to import or export files
:: Argument "Dir" is a directory dialogue to import or export directories
:: The 3 following arguments are used if the dialogue mode is set to "File"
:: The first argument is the name of the file i.e. the wild card "*"
:: The second argument is the extension of the file e.g. the wild card "exe"
:: The last argument is the description of the file e.g. "Windows Executables"
:: The arguments have to be in the following order:
:: call :fileDialog "Im" "File" "*" "hf" "Trinity List Files"
REM Exception:
:: if "%errorlevel%"=="0" (goto success ) else if "%errorlevel%"=="1" goto failed
:: if "%errorlevel%"=="2" (goto fileexists ) else if "%errorlevel%"=="3" goto filedoesnotexist
REM
::File Dialogue END


::call :choice 123456b "Make your selection: "
::Choice function START (used instead of choice.exe)
:choice "keys" "text" ex
set "%~3="
setlocal
  set "keys=%~1"
  set "text=%~2"

if exist "choice.exe" (
  
  REM choice.exe not found
  <nul set /p "=%text%" &call :choice_func %keys%
  set %~3=%errorlevel%  
  
) else (

  echo true
  pause
)
  REM Start new thread to check "file_dialog" value is valid, if not default loaded
  ::start /b "" "%~f0" launch checkChoiceFuncSwitch
  
  ::if %choice_func%==0 (

    ::<nul set /p "=%text%" &call :choice_func "%keys%"
	::set %~3=%errorlevel%  
	
  ::) else if %choice_func%==1 (
    
    ::choice /C %keys% /N /M "%text%"
	::set %~3=%errorlevel%  
  ::)
  
)

endlocal
set %~3=%errorlevel%  
exit /b


:choice_func map
setlocal DisableDelayedExpansion
set "n=0" &set "c=" &set "e=" &set "map=%~1"
if not defined map endlocal &exit /b 0
for /f "delims=" %%i in ('2^>nul xcopy /lw "%~f0" "%~f0"') do if not defined c set "c=%%i"
set "c=%c:~-1%"
if defined c (
  for /f delims^=^ eol^= %%i in ('cmd /von /u /c "echo(!map!"^|find /v ""^|findstr .') do (
    set /a "n += 1" &set "e=%%i"
    setlocal EnableDelayedExpansion
    if /i "!e!"=="!c!" (
      echo(!c!
      for /f %%j in ("!n!") do endlocal &endlocal &exit /b %%j
    )
    endlocal
  )
)
endlocal &goto choice_func
::Choice function END 


REM GetSecs "%date%" "%time%" stopsec
::Date & Time Calculation START
:GetInternational
for /f "tokens=1,2*" %%a in ('reg query "HKCU\Control Panel\International"^|find "REG_SZ" ') do set "%%a=%%c"
exit /b
:GetSecs "dateIn" "timeIn" secondsOut
setlocal
set "dateIn=%~1"
for /f "tokens=2" %%i in ("%dateIn%") do set "dateIn=%%i"
for /f "tokens=1-3 delims=%sDate%" %%a in ("%dateIn%") do (
  if %iDate%==0 set /a mm=100%%a%%100,dd=100%%b%%100,yy=10000%%c%%10000
  if %iDate%==1 set /a dd=100%%a%%100,mm=100%%b%%100,yy=10000%%c%%10000
  if %iDate%==2 set /a yy=10000%%a%%10000,mm=100%%b%%100,dd=100%%c%%100
)
for /f "tokens=1-3 delims=%sTime%%sDecimal% " %%a in ("%~2") do (
  set "hh=%%a"
  set "nn=%%b"
  set "ss=%%c"
)
if 1%hh% lss 20 set hh=0%hh%
if "%nn:~2,1%" equ "p" if "%hh%" neq "12" (set "hh=1%hh%" &set /a hh-=88)
if "%nn:~2,1%" equ "a" if "%hh%" equ "12" set "hh=00"
if "%nn:~2,1%" geq "a" set "nn=%nn:~0,2%"
set /a hh=100%hh%%%100,nn=100%nn%%%100,ss=100%ss%%%100
set /a z=14-mm,z/=12,y=yy+4800-z,m=mm+12*z-3,j=153*m+2,j=j/5+dd+y*365+y/4-y/100+y/400-2472633,j=j*86400+hh*3600+nn*60+ss
endlocal &set "%~3=%j%"
exit /b
::Date & Time Calculation END

::Get Microsoft Windows Serial Key START
:GetProductKey
setlocal EnableDelayedExpansion
set "sKeyChar=BCDFGHJKMPQRTVWXY2346789"
set "sRegKey=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
set "sRegVal=DigitalProductId"
for /f "tokens=3" %%i in ('reg query "%sRegKey%" /v "%sRegVal%"') do set "sHex=%%i"
set /a "n = 52"
for /l %%i in (104,2,132) do set /a "aRegValue_!n! = 0x!sHex:~%%i,2! , n += 1"
for /l %%b in (24,-1,0) do (
  set /a "c = 0 , n = %%b %% 5"
  for /l %%i in (66,-1,52) do set /a "c = (c << 8) + !aRegValue_%%i! , aRegValue_%%i = c / 24 , c %%= 24"
  for %%j in (!c!) do set "sProductKey=!sKeyChar:~%%j,1!!sProductKey!"
  if %%b neq 0 if !n!==0 set "sProductKey=-!sProductKey!"
)
endlocal &set "%~1=%sProductKey%"
exit /b
::Get Microsoft Windows Serial Key END

::Replace Password Character Function START
:replacepassChar
setlocal disabledelayedexpansion
for /f %%# in ('"prompt;$h&for %%# in (1) do rem"') do set "bs=%%#"
:highend
set "key="
for /f "delims=" %%# in ('xcopy /w "%~f0" "%~f0" 2^>nul') do if not defined key set "key=%%#"
set "key=%key:~-1%"
setlocal enabledelayedexpansion
if not defined key call :replacepassCharend
if %bs%==^%key% (set /p "=%bs% %bs%" <nul
set "key="
if defined passcheck set "passcheck=!passcheck:~0,-1!"
) else set /p "=*" <nul
if not defined passcheck (endlocal &set "passcheck=%key%"
) else for /f delims^=^ eol^= %%# in ("!passcheck!") do endlocal &set "passcheck=%%#%key%" 
goto :highend
exit /b

:getwindowsactivation
cscript //nologo %_slmgr% -dlv|findstr /i "Extended PID: "
cscript //nologo %_slmgr% -dli
cscript //nologo %_slmgr% -dlv|findstr /i "rearm count"
exit /b

:getEPID returnValue
cscript //nologo %_slmgr% -dlv|findstr /i "Extended PID: " >nul 2>nul
for /f "tokens=3 delims=: " %%g in ('cscript //nologo %_slmgr% -dlv^|findstr /i "Extended PID: "') do set "EPID=%%g">nul
set %~1=%EPID%
exit /b

:replacepassCharend
if "%startpassword%"=="true" goto :endhighend1
if "%hackpassword1%"=="true" set "hackpassword1=false" & goto :passHackendhighend1
if "%hackpassword2%"=="true" set "hackpassword2=false" & goto :passHackendhighend2
exit /b
::Replace Password Character Function END


::Scan _hosts/input file START
:scanhostsfile "create" "repair" "comments"
setlocal
  set "create=%~1"
  set "repair=%~2"
  set "comments=%~3"

  if %create%==true (
    if not exist "%_hosts%" (
	  REM Create new hosts file
      echo\>>"%_hosts%"
	  REM Set to read-only
      attrib +r "%_hosts%"
	  
	  REM Write log file
      call :writeLogFile "hosts file status: Created file" ex
    )
  )
  if %repair%==true (
    
	
	
	
	
	
  )
  


findstr /i "# Copyright (c) 1993-2009 Microsoft Corp." "%HostFileName%" >nul
findstr /i "#" "%HostFileName%" >nul
findstr /i "# This is a sample _hosts file used by Microsoft TCP/IP for Windows." "%HostFileName%" >nul
findstr /i "#" "%HostFileName%" >nul
findstr /i "# This file contains the mappings of IP addresses to host names. Each" "%HostFileName%" >nul
findstr /i "# entry should be kept on an individual line. The IP address should" "%HostFileName%" >nul
findstr /i "# be placed in the first column followed by the corresponding host name." "%HostFileName%" >nul
findstr /i "# The IP address and the host name should be separated by at least one" "%HostFileName%" >nul
findstr /i "# space." "%HostFileName%" >nul
findstr /i "#" "%HostFileName%" >nul
findstr /i "# Additionally, comments (such as these) may be inserted on individual" "%HostFileName%" >nul
findstr /i "# lines or following the machine name denoted by a '#' symbol." "%HostFileName%" >nul
findstr /i "#" "%HostFileName%" >nul
findstr /i "# For example:" "%HostFileName%" >nul
findstr /i "#" "%HostFileName%" >nul
findstr /i "#      102.54.94.97     rhino.acme.com          # source server" "%HostFileName%" >nul
findstr /i "#       38.25.63.10     x.acme.com              # x client host" "%HostFileName%" >nul
findstr /i "#" "%HostFileName%" >nul
findstr /i "# localhost name resolution is handled within DNS itself." "%HostFileName%" >nul
findstr /i "#    127.0.0.1       localhost" "%HostFileName%" >nul
findstr /i "#    ::1             localhost" "%HostFileName%" >nul
exit /b
::Scan _hosts/input file END

:Program_Blocker
REM This allows you to block a user with the Product ID
::if "%EPID%"=="00426-00178-926-600173-02-7177-7600.0000-1922013" goto banned
::if "%EPID%"=="12345-12345-123-123456-12-1234-1234.0000-1234567" goto banned
::if "%EPID%"=="12345-12345-123-123456-12-1234-1234.0000-1234567" goto banned
exit /b

:PCUserPassword_Blocker
if "%EPID%"=="00426-00178-926-600173-02-7177-7600.0000-1922013" set "PCuserpasswordflag=true"
::if "%EPID%"=="12345-12345-123-123456-12-1234-1234.0000-1234567" set "PCuserpasswordflag=true"
::if "%EPID%"=="12345-12345-123-123456-12-1234-1234.0000-1234567" set "PCuserpasswordflag=true"
exit /b


:MD5

::Encrypt text String START
:EncryptFunction
set "EncryptOut="
:encrypt2
set encrypt_char=%Encrypt2:~0,1%
set Encrypt2=%Encrypt2:~1%
set EncryptOut=%EncryptOut%!CHAR_EN[%encrypt_char%]!
if not "%Encrypt2%"=="" goto encrypt2
exit /b
::Encrypt text String END
::Decrypt text String START
:DecryptFunction
set "DecryptOut="
:decrypt2
set decrypt_char=%Decrypt2:~0,6%
set Decrypt2=%Decrypt2:~6%
set DecryptOut=%DecryptOut%!CHAR_DE[%decrypt_char%]!
if not "%Decrypt2%"=="" goto decrypt2
exit /b
::%Encrypt2%
::%Decrypt2%
::Decrypt text String END

:DecryptPassword
if "%passencryptmap%"=="Enabled" (
set "Decrypt2=%passwordvar%"
call :DecryptKeysV2
call :DecryptFunction )
exit /b

:EncryptKeysV1
(set CHAR_EN[a]=UDFM45) & (set CHAR_EN[b]=H21DGF) & (set CHAR_EN[c]=FDH56D) & (set CHAR_EN[d]=FGS546) & (set CHAR_EN[e]=JUK4JH)
(set CHAR_EN[f]=ERG54S) & (set CHAR_EN[g]=T5H4FD) & (set CHAR_EN[h]=RG641G) & (set CHAR_EN[i]=RG4F4D) & (set CHAR_EN[j]=RT56F6)
(set CHAR_EN[k]=VCBC3B) & (set CHAR_EN[l]=F8G9GF) & (set CHAR_EN[m]=FD4CJS) & (set CHAR_EN[n]=G423FG) & (set CHAR_EN[o]=F45GC2)
(set CHAR_EN[p]=TH5DF5) & (set CHAR_EN[q]=CV4F6R) & (set CHAR_EN[r]=XF64TS) & (set CHAR_EN[s]=X78DGT) & (set CHAR_EN[t]=TH74SJ)
(set CHAR_EN[u]=BCX6DF) & (set CHAR_EN[v]=FG65SD) & (set CHAR_EN[w]=4KL45D) & (set CHAR_EN[x]=GFH3F2) & (set CHAR_EN[y]=GH56GF)
(set CHAR_EN[z]=45T1FG) & (set CHAR_EN[1]=D4G23D) & (set CHAR_EN[2]=GB56FG) & (set CHAR_EN[3]=SF45GF) & (set CHAR_EN[4]=P4FF12)
(set CHAR_EN[5]=F6DFG1) & (set CHAR_EN[6]=56FG4G) & (set CHAR_EN[7]=USGFDG) & (set CHAR_EN[8]=FKHFDG) & (set CHAR_EN[9]=IFGJH6)
(set CHAR_EN[0]=87H8G7) & (set CHAR_EN[@]=G25GHF) & (set CHAR_EN[#]=45FGFH) & (set CHAR_EN[$]=75FG45) & (set CHAR_EN[*]=54GDH5)
(set CHAR_EN[(]=45F465) & (set CHAR_EN[.]=HG56FG) & (set CHAR_EN[,]=DF56H4) & (set CHAR_EN[-]=F5JHFH) & (set CHAR_EN[ ]=SGF4HF)
(set CHAR_EN[\]=45GH45) & (set CHAR_EN[/]=56H45G)
exit /b
:DecryptKeysV1
(set CHAR_DE[UDFM45]=a) & (set CHAR_DE[H21DGF]=b) & (set CHAR_DE[FDH56D]=c) & (set CHAR_DE[FGS546]=d) & (set CHAR_DE[JUK4JH]=e)
(set CHAR_DE[ERG54S]=f) & (set CHAR_DE[T5H4FD]=g) & (set CHAR_DE[RG641G]=h) & (set CHAR_DE[RG4F4D]=i) & (set CHAR_DE[RT56F6]=j)
(set CHAR_DE[VCBC3B]=k) & (set CHAR_DE[F8G9GF]=l) & (set CHAR_DE[FD4CJS]=m) & (set CHAR_DE[G423FG]=n) & (set CHAR_DE[F45GC2]=o)
(set CHAR_DE[TH5DF5]=p) & (set CHAR_DE[CV4F6R]=q) & (set CHAR_DE[XF64TS]=r) & (set CHAR_DE[X78DGT]=s) & (set CHAR_DE[TH74SJ]=t)
(set CHAR_DE[BCX6DF]=u) & (set CHAR_DE[FG65SD]=v) & (set CHAR_DE[4KL45D]=w) & (set CHAR_DE[GFH3F2]=x) & (set CHAR_DE[GH56GF]=y)
(set CHAR_DE[45T1FG]=z) & (set CHAR_DE[D4G23D]=1) & (set CHAR_DE[GB56FG]=2) & (set CHAR_DE[SF45GF]=3) & (set CHAR_DE[P4FF12]=4)
(set CHAR_DE[F6DFG1]=5) & (set CHAR_DE[56FG4G]=6) & (set CHAR_DE[USGFDG]=7) & (set CHAR_DE[FKHFDG]=8) & (set CHAR_DE[IFGJH6]=9)
(set CHAR_DE[87H8G7]=0) & (set CHAR_DE[G25GHF]=@) & (set CHAR_DE[45FGFH]=#) & (set CHAR_DE[75FG45]=$) & (set CHAR_DE[54GDH5]=*)
(set CHAR_DE[45F465]=() & (set CHAR_DE[HG56FG]=.) & (set CHAR_DE[DF56H4]=,) & (set CHAR_DE[F5JHFH]=-) & (set CHAR_DE[SGF4HF]= )
(set CHAR_DE[45GH45]=\) & (set CHAR_DE[56H45G]=/)
exit /b
:EncryptKeysV2
(set CHAR_EN[a]=G65FJ4) & (set CHAR_EN[b]=FGH456) & (set CHAR_EN[c]=TGH4FG) & (set CHAR_EN[d]=8R1MK3) & (set CHAR_EN[e]=XF21GR)
(set CHAR_EN[f]=DGH2GF) & (set CHAR_EN[g]=X5C4VF) & (set CHAR_EN[h]=TH5DXE) & (set CHAR_EN[i]=E5A12C) & (set CHAR_EN[j]=A5RJHA)
(set CHAR_EN[k]=52D6FG) & (set CHAR_EN[l]=A12SB1) & (set CHAR_EN[m]=9ER52S) & (set CHAR_EN[n]=5A20XS) & (set CHAR_EN[o]=4A1E1C)
(set CHAR_EN[p]=423DR1) & (set CHAR_EN[q]=412RGS) & (set CHAR_EN[r]=A4T2DS) & (set CHAR_EN[s]=C82A3U) & (set CHAR_EN[t]=5E2A6R)
(set CHAR_EN[u]=CV12HB) & (set CHAR_EN[v]=L2F5DR) & (set CHAR_EN[w]=SG4HJL) & (set CHAR_EN[x]=A54RE2) & (set CHAR_EN[y]=A52E8A)
(set CHAR_EN[z]=45D6R4) & (set CHAR_EN[1]=52R2SF) & (set CHAR_EN[2]=4GB2S6) & (set CHAR_EN[3]=A1E0SA) & (set CHAR_EN[4]=D6A3EA)
(set CHAR_EN[5]=R1E56R) & (set CHAR_EN[6]=U4D10F) & (set CHAR_EN[7]=A8W64V) & (set CHAR_EN[8]=5E5E2A) & (set CHAR_EN[9]=HY54A8)
(set CHAR_EN[0]=SDEF23) & (set CHAR_EN[@]=1W5SA2) & (set CHAR_EN[#]=LD5S3A) & (set CHAR_EN[$]=DS4A2E) & (set CHAR_EN[*]=AE2SA5)
(set CHAR_EN[(]=1BV231) & (set CHAR_EN[.]=SDFG54) & (set CHAR_EN[,]=8Z5F4T) & (set CHAR_EN[-]=SYW3AE) & (set CHAR_EN[ ]=T8A3TR)
(set CHAR_EN[\]=S21D3E) & (set CHAR_EN[/]=4E56TS)
exit /b
:DecryptKeysV2
(set CHAR_DE[G65FJ4]=a) & (set CHAR_DE[FGH456]=b) & (set CHAR_DE[TGH4FG]=c) & (set CHAR_DE[8R1MK3]=d) & (set CHAR_DE[XF21GR]=e)
(set CHAR_DE[DGH2GF]=f) & (set CHAR_DE[X5C4VF]=g) & (set CHAR_DE[TH5DXE]=h) & (set CHAR_DE[E5A12C]=i) & (set CHAR_DE[A5RJHA]=j)
(set CHAR_DE[52D6FG]=k) & (set CHAR_DE[A12SB1]=l) & (set CHAR_DE[9ER52S]=m) & (set CHAR_DE[5A20XS]=n) & (set CHAR_DE[4A1E1C]=o)
(set CHAR_DE[423DR1]=p) & (set CHAR_DE[412RGS]=q) & (set CHAR_DE[A4T2DS]=r) & (set CHAR_DE[C82A3U]=s) & (set CHAR_DE[5E2A6R]=t)
(set CHAR_DE[CV12HB]=u) & (set CHAR_DE[L2F5DR]=v) & (set CHAR_DE[SG4HJL]=w) & (set CHAR_DE[A54RE2]=x) & (set CHAR_DE[A52E8A]=y)
(set CHAR_DE[45D6R4]=z) & (set CHAR_DE[52R2SF]=1) & (set CHAR_DE[4GB2S6]=2) & (set CHAR_DE[A1E0SA]=3) & (set CHAR_DE[D6A3EA]=4)
(set CHAR_DE[R1E56R]=5) & (set CHAR_DE[U4D10F]=6) & (set CHAR_DE[A8W64V]=7) & (set CHAR_DE[5E5E2A]=8) & (set CHAR_DE[HY54A8]=9)
(set CHAR_DE[SDEF23]=0) & (set CHAR_DE[1W5SA2]=@) & (set CHAR_DE[LD5S3A]=#) & (set CHAR_DE[DS4A2E]=$) & (set CHAR_DE[AE2SA5]=*)
(set CHAR_DE[1BV231]=() & (set CHAR_DE[SDFG54]=.) & (set CHAR_DE[8Z5F4T]=,) & (set CHAR_DE[SYW3AE]=-) & (set CHAR_DE[T8A3TR]= )
(set CHAR_DE[S21D3E]=\) & (set CHAR_DE[4E56TS]=/)
exit /b
REM Functions END
::END OF PROGRAM