@echo off
echo ===================================================
echo Stopping Elderly Smartphone Learning App...
echo ===================================================

echo Terminating web server processes on port 8080...
taskkill /F /IM python.exe >nul 2>nul
taskkill /F /IM pythonw.exe >nul 2>nul

powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { if ($_ -gt 0) { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue } }" >nul 2>nul

echo.
echo ===================================================
echo Web application server on port 8080 has been stopped.
echo ===================================================
pause
