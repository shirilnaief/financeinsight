@echo off
setlocal enabledelayedexpansion

set PORT=%1
if "%PORT%"=="" set PORT=4028
set FALLBACK_PORT=4029

echo Attempting to start Flutter web server on port %PORT%...

:: Check if port is in use
netstat -ano | findstr :%PORT% >nul
if !errorlevel! equ 0 (
    echo Port %PORT% is already in use. Attempting to kill the process...
    
    :: Get PID and kill the process
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :%PORT%') do (
        taskkill /PID %%a /F >nul 2>&1
    )
    
    :: Wait a moment for the process to terminate
    timeout /t 2 >nul
    
    :: Check if port is still in use
    netstat -ano | findstr :%PORT% >nul
    if !errorlevel! equ 0 (
        echo Could not free port %PORT%. Using fallback port %FALLBACK_PORT%...
        set PORT=%FALLBACK_PORT%
    ) else (
        echo Port %PORT% is now available.
    )
) else (
    echo Port %PORT% is available.
)

:: Start Flutter web development server
echo Starting Flutter web server on port %PORT%...
flutter run -d web-server --web-port %PORT% --web-hostname 0.0.0.0