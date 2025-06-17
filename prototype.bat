@echo off

cd /d "%~dp0"

set APP_PATH=%~dp0
set LAUNCH_PATH=%APP_PATH%prototype.py

if not exist "%APP_PATH%abcv\Scripts\python.exe" (
    echo INSTALLING VIRTUAL ENVIRIONMENT
	
    %APP_PATH%pyside-installer\mpym\pyside-installer.exe -m virtualenv .\abcv
	
	echo INSTALLING PYSIDE6
	%APP_PATH%abcv\Scripts\python.exe -m pip install --no-input pyside6==6.9.0

)

echo LAUNCHING PROTOTYPE.PY
cd .\abcv\Scripts\ 
call .\python.exe %LAUNCH_PATH%

pause

