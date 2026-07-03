@echo off
REM ============================================================
REM KRR Project - Final Verification & Quick Test
REM Tests that both backend and frontend can start
REM ============================================================

cls
echo.
echo ========================================
echo   KRR Project - Startup Test
echo ========================================
echo.

cd /d "%~dp0"
set "SCRIPT_DIR=%cd%"

REM Activate venv
call venv\Scripts\activate.bat >nul 2>&1

echo Testing backend imports...
python -c "import uvicorn, fastapi, pydantic, groq, fitz; print('[OK] Backend modules imported successfully')" 2>nul
if !errorlevel! neq 0 (
    echo [ERROR] Backend import failed
    pause
    exit /b 1
)

echo Testing backend main module...
cd backend
python -c "from app.main import app; print('[OK] Backend main module loaded')" 2>nul
if !errorlevel! neq 0 (
    echo [ERROR] Backend main module failed
    cd ..
    pause
    exit /b 1
)
cd ..

echo Testing frontend module imports...
cd frontend
if not exist "package.json" (
    echo [ERROR] Frontend package.json not found
    cd ..
    pause
    exit /b 1
) else (
    echo [OK] Frontend package.json found
)

if not exist "node_modules" (
    echo [ERROR] Frontend node_modules not found
    echo Run: npm install in frontend folder
    cd ..
    pause
    exit /b 1
) else (
    echo [OK] Frontend node_modules exists
)

if not exist ".env.local" (
    echo [INFO] No .env.local in frontend (optional)
) else (
    echo [OK] .env.local exists
)

cd ..

echo.
echo ========================================
echo   All Checks Passed!
echo ========================================
echo.
echo You can now safely run:  startup1.bat
echo.
pause
exit /b 0
