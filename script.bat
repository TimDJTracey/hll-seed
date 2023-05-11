@echo off
for /f "delims=" %%x in (config.txt) do (set "%%x")

START "" %SERVER_URL%
timeout /t 120 >nul
START "" %SERVER_URL%


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

TASKKILL /IM HLL-Win64-Shipping.exe /F