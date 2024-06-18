@echo off
for /f "delims=" %%x in (config.txt) do (set "%%x")

echo Checking to see if HLL is running...
set "APPLICATION=HLL-Win64-Shipping.exe"

::tasklist /FI "IMAGENAME eq %APPLICATION%" 2>NUL | find /I "%APPLICATION%" >NUL
::if "%errorlevel%"=="0" (
::    echo The application %APPLICATION% is running.
::    exit
::) else (
:;    echo The application %APPLICATION% is not running.
::)
::echo.



echo Launching Seed...
REM START "" %SERVER_URL%
REM timeout /t 120 >nul
REM START "" %SERVER_URL%



echo.

echo Checking Player counts ..

for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URL% ^| %JQ_PATH% -r ".result.players.allied"`) do set alliedcount=%%i
for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URL% ^| %JQ_PATH% -r ".result.players.axis"`) do set axiscount=%%i

 
echo.Allied Faction has %alliedcount% players
echo.Axis Faction has %axiscount% players

if %alliedcount% leq %axiscount% (
echo Launching as Allies
SpawnSL.exe Allied 
timeout /t 30 >nul
goto loop
) else (
echo Launching as Axis
SpawnSL.exe Axis 
timeout /t 30 >nul

goto loop
)



:loop

for /f "usebackq delims=," %%i in (`curl -s -X GET %RCON_URL% ^| %JQ_PATH% -r ".result.player_count"`) do set count=%%i

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

echo Putting the PC to sleep...
REM powercfg -h off
REM rundll32.exe powrprof.dll,SetSuspendState 0,1,0
REM powercfg -h on

echo PC is now asleep.
