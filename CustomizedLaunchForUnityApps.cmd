@echo off
title Customized Launch For Unity Apps
cls

set _appName=CustomizedLaunchForUnityApps
set _appLocation=%~dp0%~n0%~x0


set adminrights=false
net session>nul 2>&1
if %errorLevel%==0 (
	set adminrights=true
)

set inputArgs=%1
if %inputArgs% equ --enable_contextmenu (

    if %adminrights%==true (
		reg add "HKEY_CLASSES_ROOT\exefile\shell\%_appName%" /f
		reg add "HKEY_CLASSES_ROOT\exefile\shell\%_appName%" /f /ve /d "%_appName%"
		reg add "HKEY_CLASSES_ROOT\exefile\shell\%_appName%\command" /f
		reg add "HKEY_CLASSES_ROOT\exefile\shell\%_appName%\command" /f /ve /d "\"%_appLocation%\" \"%%1\""
    ) else (
        echo You don't have admin rights. Please, call me when you've got that!
		echo.
		pause
	)
	goto quitconsole
	
) else if %inputArgs% equ --remove_contextmenu (

    if %adminrights%==true (
		reg delete "HKEY_CLASSES_ROOT\exefile\shell\%_appName%" /f
    ) else (
        echo You don't have admin rights. Please, call me when you've got that!
		echo.
		pause
		
	)
	goto quitconsole
)


set _filepath=%~dp1
set _filename=%~n1
set _fileextension=%~x1
set _validext=.exe
set _configfile=%_filename%_CustomWindowCFG.txt
set _defWinF=0
set _defWinW=1280
set _defWinH=720
set _winF=%_defWinF%
set _winW=%_defWinW%
set _winH=%_defWinH%


if not exist "%_filepath%" goto error_invalidpath
if not %_fileextension% == %_validext% goto error_wrongfileextension
if not exist "%_filepath%%_filename%_Data\" goto error_notgameandormadewithunity
if not exist "%_filepath%UnityPlayer.dll" goto error_notgameandormadewithunity
if not exist "%_filepath%%_filename%_Data\Managed\UnityEngine.dll" goto error_notgameandormadewithunity
:giveitatry


set tmp1=_%_appName%
reg query "HKEY_CURRENT_USER\SOFTWARE\%tmp1%">nul 2>&1
if %errorlevel%==1 (
	reg add "HKEY_CURRENT_USER\SOFTWARE\%tmp1%">nul 2>&1
)
set tmp2=%tmp1%\%_filename%
reg query "HKEY_CURRENT_USER\SOFTWARE\%tmp2%">nul 2>&1
if %errorlevel%==1 (
	reg add "HKEY_CURRENT_USER\SOFTWARE\%tmp2%">nul 2>&1
)
reg query "HKEY_CURRENT_USER\SOFTWARE\%tmp2%" /v "fullscreen">nul 2>&1
if %errorlevel%==0 (
	for /f "tokens=2*" %%A in ('reg.exe query "HKEY_CURRENT_USER\SOFTWARE\%tmp2%" /v "fullscreen"') do (set _winF=%%B)
)
reg query "HKEY_CURRENT_USER\SOFTWARE\%tmp2%" /v "width">nul 2>&1
if %errorlevel%==0 (
	for /f "tokens=2*" %%A in ('reg.exe query "HKEY_CURRENT_USER\SOFTWARE\%tmp2%" /v "width"') do (set _winW=%%B)
)
reg query "HKEY_CURRENT_USER\SOFTWARE\%tmp2%" /v "height">nul 2>&1
if %errorlevel%==0 (
	for /f "tokens=2*" %%A in ('reg.exe query "HKEY_CURRENT_USER\SOFTWARE\%tmp2%" /v "height"') do (set _winH=%%B)
)

echo %_winF%| findstr /r "^[1-9][0-9]*$">nul
if not %errorlevel% equ 0 (set _winF=%_defWinF%)
echo %_winW%| findstr /r "^[1-9][0-9]*$">nul
if not %errorlevel% equ 0 (set _winW=%_defWinW%&set _winH=%_defWinH%)
echo %_winH%| findstr /r "^[1-9][0-9]*$">nul
if not %errorlevel% equ 0 (set _winW=%_defWinW%&set _winH=%_defWinH%)



set tmp_disp=0

goto saveconfig
:main
cls
set launchloc="%_filepath%%_filename%%_fileextension%" -screen-width %_winW% -screen-height %_winH% -screen-fullscreen %_winF%

echo.
if %tmp_disp%==0 (
	echo   GAME:  %_filename%  [%_fileextension%]
	echo.
	set tmp_disp=1
) else (
	if %tmp_disp%==1 (
		echo   PATH:  %_filepath%
		echo PARAMS:  -screen-width %_winW% -screen-height %_winH% -screen-fullscreen %_winF%
		set tmp_disp=0
	)
)
echo.
echo [1]  640 x 480  [4:3]  I  [t]  1280 x 720  [16:9]
echo [2]  768 x 480  [8:5]  I  [z]  1024 x 768   [4:3]
echo [3]  800 x 480  [5:3]  I  [u]  1152 x 720   [8:5]
echo [4]  854 x 480 [16:9]  I  [i]  1280 x 720  [16:9]
echo [5]  800 x 600  [4:3]  I  [o]  1280 x 768   [5:3]
echo [6]  960 x 540 [16:9]  I  [p]  1152 x 864   [4:3]
echo [7]  832 x 624  [4:3]  I  [a]  1280 x 800   [8:5]
echo [8]  960 x 544 [16:9]  I  [s]  1280 x 960   [4:3]
echo [9] 1024 x 576 [16:9]  I  [d]  1440 x 900   [8:5]
echo [q] 1024 x 600 [16:9]  I  [f]  1600 x 900  [16:9]
echo [w]  960 x 640  [3:2]  I  [g]  1440 x 1080  [4:3]
echo [e] 1024 x 640  [8:5]  I  [h]  1600 x 1200  [4:3]
echo [r]  960 x 720  [4:3]  I  [j]  1920 x 1080 [16:9]
echo.

set log=[y]  Fullscreen:  
if %_winF%==0 set log=%log%FALSE
if %_winF%==1 set log=%log%TRUE
echo %log%
set log=[x]  Resolution:  %_winW%x%_winH%
echo %log%
echo [c]  Launch
echo [v]  Quit
echo.

choice /t 3 /d M /c 123456789qwertzuiopasdfghjyxcvM /n /m "Choose an option by pressing the right key!"
if %errorlevel%==1 set _winW=640&set _winH=480&goto saveconfig
if %errorlevel%==2 set _winW=768&set _winH=480&goto saveconfig
if %errorlevel%==3 set _winW=800&set _winH=480&goto saveconfig
if %errorlevel%==4 set _winW=854&set _winH=480&goto saveconfig
if %errorlevel%==5 set _winW=800&set _winH=600&goto saveconfig
if %errorlevel%==6 set _winW=960&set _winH=540&goto saveconfig
if %errorlevel%==7 set _winW=832&set _winH=624&goto saveconfig
if %errorlevel%==8 set _winW=960&set _winH=544&goto saveconfig
if %errorlevel%==9 set _winW=1024&set _winH=576&goto saveconfig
if %errorlevel%==10 set _winW=1024&set _winH=600&goto saveconfig
if %errorlevel%==11 set _winW=960&set _winH=640&goto saveconfig
if %errorlevel%==12 set _winW=1024&set _winH=640&goto saveconfig
if %errorlevel%==13 set _winW=960&set _winH=720&goto saveconfig

if %errorlevel%==14 set _winW=1280&set _winH=720&goto saveconfig
if %errorlevel%==15 set _winW=1024&set _winH=768&goto saveconfig
if %errorlevel%==16 set _winW=1152&set _winH=720&goto saveconfig
if %errorlevel%==17 set _winW=1280&set _winH=720&goto saveconfig
if %errorlevel%==18 set _winW=1280&set _winH=768&goto saveconfig
if %errorlevel%==19 set _winW=1152&set _winH=864&goto saveconfig
if %errorlevel%==20 set _winW=1280&set _winH=800&goto saveconfig
if %errorlevel%==21 set _winW=1280&set _winH=960&goto saveconfig
if %errorlevel%==22 set _winW=1440&set _winH=900&goto saveconfig
if %errorlevel%==23 set _winW=1600&set _winH=900&goto saveconfig
if %errorlevel%==24 set _winW=1440&set _winH=1080&goto saveconfig
if %errorlevel%==25 set _winW=1600&set _winH=1200&goto saveconfig
if %errorlevel%==26 set _winW=1920&set _winH=1080&goto saveconfig

if %errorlevel%==27 if %_winF%==1 (set _winF=0&goto saveconfig) else (set _winF=1&goto saveconfig)
if %errorlevel%==28 goto customresolution
if %errorlevel%==29 goto startapp
if %errorlevel%==30 goto quitconsole
goto main


:saveconfig
cls
reg query "HKEY_CURRENT_USER\SOFTWARE\%tmp2%">nul 2>&1
if %errorlevel%==0 (
	reg add "HKEY_CURRENT_USER\SOFTWARE\%tmp2%" /v "fullscreen" /t REG_SZ /d %_winF% /f>nul 2>&1
	reg add "HKEY_CURRENT_USER\SOFTWARE\%tmp2%" /v "width" /t REG_SZ /d %_winW% /f>nul 2>&1
	reg add "HKEY_CURRENT_USER\SOFTWARE\%tmp2%" /v "height" /t REG_SZ /d %_winH% /f>nul 2>&1
)
goto main


:customresolution
cls
:cusreserr
set /p _winW=Width: 
echo %_winW%| findstr /r "^[1-9][0-9]*$">nul
if not %errorlevel% equ 0 (
	cls
	echo Invalid number. Try again!
	echo.
	goto cusreserr
)
set /p _winH=Height: 
echo %_winH%| findstr /r "^[1-9][0-9]*$">nul
if not %errorlevel% equ 0 (
	cls
	echo Invalid number. Try again!
	echo.
	goto cusreserr
)
goto saveconfig


:startapp
start "" %launchloc%
goto quitconsole


:error_invalidpath
echo Invalid location.
echo Please drag and drop an executeable file onto this batch file!
echo.
pause
goto quitconsole

:error_wrongfileextension
echo Wrong file extension.
echo Please drag and drop an EXECUTEABLE file onto this batch file!
echo.
pause
goto quitconsole

:error_notgameandormadewithunity
echo This executeable file is probably not a made-with-unity game's executeable file.
echo Please drag and drop THE RIGHT (made-with-unity) game's EXECUTEABLE FILE onto this batch file!
echo.
choice /c yn /n /m "...or Do you want to give it a try? [Y]es/[N]o"
if %errorlevel%==1 goto giveitatry
goto quitconsole


:quitconsole