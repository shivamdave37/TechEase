@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo Starting Elderly Smartphone Learning App (Web)...
echo ===================================================

cd /d "%~dp0"

:: 1. Locate Python executable (check PATH, AppData, and standard folders)
set "PYTHON_EXE="

where python >nul 2>nul
if %errorlevel% equ 0 (
    set "PYTHON_EXE=python"
)

if not defined PYTHON_EXE (
    if exist "%LOCALAPPDATA%\Programs\Python\Python313\python.exe" (
        set "PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
    ) else if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" (
        set "PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
    ) else if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" (
        set "PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
    ) else if exist "C:\Python313\python.exe" (
        set "PYTHON_EXE=C:\Python313\python.exe"
    ) else if exist "C:\Python312\python.exe" (
        set "PYTHON_EXE=C:\Python312\python.exe"
    )
)

:: 2. Check build folder
if not exist "build\web\index.html" (
    echo Building web release bundle...
    call C:\src\flutter-sdk\bin\flutter.bat build web --release
)

:: 3. Start web server (with automatic fallback to native PowerShell if Python is missing)
if defined PYTHON_EXE (
    echo Starting web server using Python...
    start /b "" "!PYTHON_EXE!" -m http.server 8080 --directory "build\web"
) else (
    echo Starting web server using native Windows PowerShell...
    start /b "" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve.ps1"
)

ping 127.0.0.1 -n 3 >nul
echo Opening application in default browser...
start http://localhost:8080

echo.
echo ===================================================
echo App is live and running at: http://localhost:8080
echo To stop the app, run 'stop_app.bat' or close this window.
echo ===================================================
pause
