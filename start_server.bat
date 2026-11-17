@echo off
title Elderly Smartphone Learning App Server
echo ===================================================
echo Starting Elderly Smartphone Learning App Web Server
echo ===================================================
cd /d "%~dp0"

where python >nul 2>nul
if %ERRORLEVEL% equ 0 (
    python serve.py
    goto end
)

if exist "C:\Users\shiva\AppData\Local\Programs\Python\Python313\python.exe" (
    "C:\Users\shiva\AppData\Local\Programs\Python\Python313\python.exe" serve.py
    goto end
)

echo Python was not found in PATH or standard directory!
pause

:end
