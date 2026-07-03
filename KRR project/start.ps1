# KRR Project Start Script (PowerShell)
# Starts both backend and frontend servers

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  KRR Project Startup Script (PowerShell)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $SCRIPT_DIR

if (-not (Test-Path ".env")) {
    Write-Host "ERROR: .env file not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Checking prerequisites..." -ForegroundColor Blue
Write-Host ""

# Check if ports are available
$port8000 = netstat -ano | Select-String ":8000"
$port5173 = netstat -ano | Select-String ":5173"

if ($port8000) {
    Write-Host "Port 8000 is already in use" -ForegroundColor Red
    exit 1
}

if ($port5173) {
    Write-Host "Port 5173 is already in use" -ForegroundColor Red
    exit 1
}

Write-Host "OK Ports 8000 and 5173 available" -ForegroundColor Green
Write-Host ""

# Create logs directory
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" | Out-Null
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "   Starting Both Servers..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Starting Backend (Port 8000)..." -ForegroundColor Cyan
Set-Location "$SCRIPT_DIR\backend"
$backendJob = Start-Job -ScriptBlock {
    Set-Location $args[0]
    & python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
} -ArgumentList "$SCRIPT_DIR\backend"

Write-Host "OK Backend started" -ForegroundColor Green

Start-Sleep -Seconds 2

Write-Host "Starting Frontend (Port 5173)..." -ForegroundColor Cyan
Set-Location "$SCRIPT_DIR\frontend"
$frontendJob = Start-Job -ScriptBlock {
    Set-Location $args[0]
    & npm run dev
} -ArgumentList "$SCRIPT_DIR\frontend"

Write-Host "OK Frontend started" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   Both Servers Running!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access URLs:" -ForegroundColor Blue
Write-Host "   Frontend (localhost): http://localhost:5173" -ForegroundColor Cyan
Write-Host "   Frontend (loopback):  http://127.0.0.1:5173" -ForegroundColor Cyan
Write-Host "   Backend (localhost):  http://localhost:8000" -ForegroundColor Cyan
Write-Host "   Backend (loopback):   http://127.0.0.1:8000" -ForegroundColor Cyan
Write-Host "   Backend API docs:     http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop both servers" -ForegroundColor Yellow
Write-Host ""

# Wait for jobs
while ($true) {
    if ((Get-Job -Id $backendJob.Id).State -eq "Failed" -or (Get-Job -Id $frontendJob.Id).State -eq "Failed") {
        Write-Host "WARNING: One of the servers has stopped" -ForegroundColor Yellow
        break
    }
    Start-Sleep -Seconds 1
}

# Cleanup
Write-Host ""
Write-Host "Shutting down servers..." -ForegroundColor Yellow
Stop-Job -Id $backendJob.Id, $frontendJob.Id
Remove-Job -Id $backendJob.Id, $frontendJob.Id
Write-Host "OK Servers stopped" -ForegroundColor Green
