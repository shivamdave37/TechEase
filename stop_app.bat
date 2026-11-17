@echo off
echo Stopping any running web server on port 8080...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8080" ^| findstr "LISTENING"') do (
    echo Stopping process PID %%a...
    taskkill /F /PID %%a
)
echo Application stopped.
pause
