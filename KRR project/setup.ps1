# KRR Project Setup Script (PowerShell)
# This script installs all dependencies for both frontend and backend

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  KRR Project Setup Script (PowerShell)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $SCRIPT_DIR

# Check Python
Write-Host "Checking prerequisites..." -ForegroundColor Blue
Write-Host ""

try {
    $pythonVersion = & python --version 2>&1
    Write-Host "OK Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "FAILED Python is not installed" -ForegroundColor Red
    Write-Host "Please install Python 3 from https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}

# Check Node.js
try {
    $nodeVersion = & node --version
    Write-Host "OK Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "FAILED Node.js is not installed" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check npm
try {
    $npmVersion = & npm --version
    Write-Host "OK npm found: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "FAILED npm is not installed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Installing Backend Dependencies..." -ForegroundColor Blue
Write-Host ""

if (Test-Path "requirements.txt") {
    Write-Host "Installing Python packages..."
    & pip install -q -r requirements.txt
    Write-Host "OK Backend dependencies installed" -ForegroundColor Green
} else {
    Write-Host "WARNING requirements.txt not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Installing Frontend Dependencies..." -ForegroundColor Blue
Write-Host ""

Set-Location "$SCRIPT_DIR\frontend"
if (Test-Path "package.json") {
    Write-Host "Installing npm packages..."
    & npm install --force --quiet
    Write-Host "OK Frontend dependencies installed" -ForegroundColor Green
} else {
    Write-Host "WARNING package.json not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Configuration Check..." -ForegroundColor Blue
Write-Host ""

Set-Location $SCRIPT_DIR

if (-not (Test-Path ".env")) {
    Write-Host "WARNING .env file not found" -ForegroundColor Yellow
    Write-Host "Creating .env from .env.example..."
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "OK .env file created" -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANT: Edit .env and add your GROQ_API_KEY!" -ForegroundColor Yellow
        Write-Host "Get a free key at: https://console.groq.com/keys" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "WARNING .env.example not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "OK .env file found" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "      Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
