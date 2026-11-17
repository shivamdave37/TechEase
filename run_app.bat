@echo off
echo ===================================================
echo Starting Elderly Smartphone Learning App (Web)...
echo ===================================================

cd /d "%~dp0"

echo Building web release bundle if missing...
if not exist "build\web\index.html" (
    call C:\src\flutter-sdk\bin\flutter.bat build web --release
)

echo Starting local web server on port 8080...
start /b python -m http.server 8080 --directory "build\web"

timeout /t 2 /nobreak >nul
echo Opening application in default browser...
start http://localhost:8080

echo.
echo App is accessible at: http://localhost:8080
echo To stop the application, run 'stop_app.bat' or close the terminal window.
echo ===================================================
pause
