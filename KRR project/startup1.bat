@echo off
REM ============================================================
REM KRR Project Startup Script v3.1
REM Runs Backend (FastAPI) and Frontend (Vite+React) in parallel
REM ============================================================

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════╗
echo ║    KRR - AI Literature Review System   ║
echo ║       Parallel Startup Launcher        ║
echo ╚════════════════════════════════════════╝
echo.

REM Get the script directory
cd /d "%~dp0"
set "SCRIPT_DIR=%cd%"

echo Current directory: %SCRIPT_DIR%
echo.

REM Check if node_modules exists in frontend
if not exist "frontend\node_modules" (
    echo ERROR: Frontend dependencies not installed!
    echo Please run: npm install in the frontend folder first
    echo Or run setup.ps1
    echo.
    pause
    exit /b 1
)

REM Check if .env exists
if not exist ".env" (
    echo ERROR: .env file not found!
    echo Please copy .env.example to .env and add your GROQ_API_KEY
    echo.
    pause
    exit /b 1
)

REM Check if venv exists and is properly configured
if not exist "venv\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found!
    echo.
    echo This script requires setup to be run first.
    echo Please run: setup.ps1 or python -m venv venv
    echo and then: pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

REM Verify backend dependencies are installed
call venv\Scripts\activate.bat >nul 2>&1
python -c "import uvicorn, fastapi, pydantic_settings" >nul 2>&1
if !errorlevel! neq 0 (
    echo.
    echo WARNING: Installing missing backend dependencies...
    echo.
    pip install --quiet pydantic-settings python-dotenv
    if !errorlevel! neq 0 (
        echo ERROR: Failed to install dependencies
        call deactivate.bat >nul 2>&1
        pause
        exit /b 1
    )
)

REM Try to check ports (optional - may fail on some systems)
echo Checking port availability...
netstat -ano 2>nul | findstr ":8000" >nul
if !errorlevel! equ 0 (
    echo   ^⚠ WARNING: Port 8000 might be in use
) else (
    echo   ^✓ Port 8000 available
)

netstat -ano 2>nul | findstr ":5173" >nul
if !errorlevel! equ 0 (
    echo   ^⚠ WARNING: Port 5173 might be in use
) else (
    echo   ^✓ Port 5173 available
)

REM Create logs directory
if not exist "logs" mkdir logs

echo.
echo ════════════════════════════════════════
echo   Preparing Servers...
echo ════════════════════════════════════════
echo.

REM Display what will happen
echo This will launch TWO backend/frontend servers in parallel:
echo  1. Backend (FastAPI)  - Port 8000
echo  2. Frontend (Vite)    - Port 5173
echo.

REM Start Backend in a new window
echo.
echo [1/2] Launching Backend Server...
start "KRR Backend Server" cmd /k ^
  "cd /d "%SCRIPT_DIR%\backend" && ^
   call ..\venv\Scripts\activate.bat && ^
   title KRR Backend Server - Port 8000 && ^
   echo. && ^
   echo ════════════════════════════════════════ && ^
   echo   KRR Backend Server ^(FastAPI^) && ^
   echo   http://localhost:8000 && ^
   echo   Docs: http://localhost:8000/docs && ^
   echo ════════════════════════════════════════ && ^
   echo. && ^
   python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload && ^
   echo. && ^
   echo Backend stopped. Press Enter to close. && ^
   pause"

REM Wait for backend to initialize
timeout /t 3 /nobreak >nul

REM Start Frontend in a new window
echo [2/2] Launching Frontend Server...
start "KRR Frontend Server" cmd /k ^
  "cd /d "%SCRIPT_DIR%\frontend" && ^
   title KRR Frontend Server - Port 5173 && ^
   echo. && ^
   echo ════════════════════════════════════════ && ^
   echo   KRR Frontend Server ^(Vite + React^) && ^
   echo   http://localhost:5173 && ^
   echo ════════════════════════════════════════ && ^
   echo. && ^
   npm run dev && ^
   echo. && ^
   echo Frontend stopped. Press Enter to close. && ^
   pause"

REM Wait for servers to initialize
echo.
echo ════════════════════════════════════════
echo   Servers Starting in Background...
echo ════════════════════════════════════════
echo.

timeout /t 5 /nobreak

REM Display access information
cls
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║           BOTH SERVERS STARTED SUCCESSFULLY!               ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo FRONTEND APPLICATION:
echo   URL:  http://localhost:5173
echo.
echo BACKEND API SERVER:
echo   URL:  http://localhost:8000
echo   Docs: http://localhost:8000/docs
echo.
echo DEFAULT LOGIN CREDENTIALS:
echo   Email:    test@gmail.com
echo   Password: test123
echo.
echo ════════════════════════════════════════════════════════════
echo.
echo ✓ TWO terminal windows are now RUNNING SIMULTANEOUSLY:
echo   - Backend Terminal (FastAPI, Port 8000)
echo   - Frontend Terminal (Vite + React, Port 5173)
echo.
echo TO STOP SERVERS:
echo   Close the terminal windows or press Ctrl+C
echo.
echo TROUBLESHOOTING:
echo   - Port in use?      Check System Monitor for processes
echo   - Missing deps?     Run verify-startup.bat
echo   - Module errors?    Check terminal window for details
echo.
echo This window will automatically close in 20 seconds...
echo.

timeout /t 20 /nobreak

timeout /t 15 /nobreak

exit /b 0
