@echo off
for /f "delims=" %%x in (config.txt) do (set "%%x")

echo Checking to see if HLL is running...
set "APPLICATION=HLL-Win64-Shipping.exe"

tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I "%APPLICATION%" >NUL
if "%errorlevel%"=="0" (
    echo The application %APPLICATION% is running.
    exit
) else (
    echo The application %APPLICATION% is not running.
)
echo.

echo Launching Seed...
START "" %SERVER_URL%
timeout /t 120 >nul
START "" %SERVER_URL%

echo.

echo Waiting until seeded...
:loop
for /f "usebackq delims=" %%i in (`curl -s -X GET %RCON_URL% ^| %JQ_PATH% -r ".result.player_count"`) do set count=%%i

if %count% gtr %SEEDED_THRESHOLD% (
    echo Player count is greater than %SEEDED_THRESHOLD%.
    goto endloop
) else (
    echo Player count is %count%. Waiting 30 seconds...
    timeout /t 30 >nul
    goto loop
)

:endloop
echo.

echo Server is seeded. Killing game...

TASKKILL /IM HLL-Win64-Shipping.exe /F

echo Waiting for HLL to finish closing
timeout /t 60 >nul 
