@echo off
REM ============================================================
REM KRR Project Startup Script (Windows Batch)
REM Runs Backend and Frontend in parallel with one click
REM ============================================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   KRR Project - One Click Startup
echo ========================================
echo.

cd /d "%~dp0"

REM Check if venv exists
if not exist "venv" (
    echo ERROR: Virtual environment not found!
    echo Please run setup.ps1 first to install dependencies.
    echo.
    pause
    exit /b 1
)

REM Check if .env exists
if not exist ".env" (
    echo ERROR: .env file not found!
    echo Please run setup.ps1 first.
    echo.
    pause
    exit /b 1
)

echo Checking ports...
netstat -ano | findstr ":8000" >nul
if !errorlevel! equ 0 (
    echo ERROR: Port 8000 is already in use!
    echo Please close the application using port 8000.
    echo.
    pause
    exit /b 1
)

netstat -ano | findstr ":5173" >nul
if !errorlevel! equ 0 (
    echo ERROR: Port 5173 is already in use!
    echo Please close the application using port 5173.
    echo.
    pause
    exit /b 1
)

echo OK Ports 8000 and 5173 are available
echo.

REM Create logs directory if it doesn't exist
if not exist "logs" mkdir logs

echo ========================================
echo   Starting Backend & Frontend...
echo ========================================
echo.

REM Start Backend in a new window
echo Starting Backend (Port 8000)...
start "KRR Backend" cmd /k "cd /d "%cd%\backend" && ..\venv\Scripts\activate.bat && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"

REM Wait 2 seconds
timeout /t 2 /nobreak

REM Start Frontend in a new window
echo Starting Frontend (Port 5173)...
start "KRR Frontend" cmd /k "cd /d "%cd%\frontend" && ..\venv\Scripts\activate.bat && npm run dev"

echo.
echo ========================================
echo   Both Servers Started!
echo ========================================
echo.
echo Access URLs:
echo   Frontend: http://localhost:5173
echo   Backend:  http://localhost:8000
echo   API Docs: http://localhost:8000/docs
echo.
echo Two terminal windows should have opened above.
echo Close either terminal to stop that server.
echo.
pause
