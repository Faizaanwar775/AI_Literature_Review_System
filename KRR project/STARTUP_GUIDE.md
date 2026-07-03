# KRR Project - Starting Both Backend & Frontend

## Quick Start

Run this command to start both servers in parallel:

```bash
startup1.bat
```

This will:
1. ✅ Start the **Backend Server** on port 8000
2. ✅ Start the **Frontend Server** on port 5173
3. ✅ Open both in separate terminal windows
4. ✅ Display access URLs and login credentials

---

## What Gets Started

### Backend (FastAPI)
- **URL:** http://localhost:8000
- **API Docs:** http://localhost:8000/docs
- **Type:** Python + uvicorn server
- **Port:** 8000
- **Terminal:** "KRR Backend Server"

### Frontend (Vite + React)
- **URL:** http://localhost:5173
- **Type:** Node.js + React development server
- **Port:** 5173
- **Terminal:** "KRR Frontend Server"

---

## Default Login Credentials

```
Email:    test@gmail.com
Password: test123
```

---

## Prerequisites

**IMPORTANT:** Before running `startup1.bat` for the first time:

1. **Python 3.9+** must be installed
   ```bash
   python --version
   ```

2. **Node.js & npm** must be installed
   ```bash
   npm --version
   ```

3. **Virtual Environment Setup**
   ```bash
   python -m venv venv
   ```

4. **Install Backend Dependencies**
   ```bash
   .\venv\Scripts\activate.bat
   pip install -r requirements.txt
   ```

5. **Install Frontend Dependencies**
   ```bash
   cd frontend
   npm install
   cd ..
   ```

6. **.env Configuration** - Must have GROQ_API_KEY set
   ```
   GROQ_API_KEY="your_api_key_here"
   ```

---

## Automated Setup

If you haven't set up the project yet, run:

```bash
verify-startup.bat
```

This will automatically:
- Check for Python and Node.js
- Create virtual environment if needed
- Install all backend dependencies
- Install all frontend dependencies
- Verify ports are available
- Report any issues

---

## Troubleshooting

### Port Already in Use

If you see "Port 8000 in use" or "Port 5173 in use":

**Option 1:** Find and close the process
```powershell
# Find process on port 8000
Get-NetTCPConnection -LocalPort 8000 | Format-Table

# Kill process (replace PID with actual process ID)
Stop-Process -Id <PID> -Force
```

**Option 2:** Use different ports
- Backend: `python -m uvicorn app.main:app --port 8001`
- Frontend: Change in `vite.config.js` and `package.json`

### Missing Dependencies

Solution:
```bash
.\venv\Scripts\activate.bat
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

### Frontend Not Starting

Solution:
```bash
cd frontend
npm install
npm run dev
```

### Backend ImportError

Solution:
```bash
.\venv\Scripts\activate.bat
python -c "import uvicorn, fastapi"
pip install -r requirements.txt
```

### Network Issues During Installation

If pip times out:
```bash
pip install --default-timeout=1000 -r requirements.txt
```

---

## Stopping the Servers

Simply close the terminal windows, or press `Ctrl+C` in each window.

---

## Environment Variables

The project uses a `.env` file for configuration:

```
GROQ_API_KEY=your_groq_api_key_here
```

Get a free API key at: https://console.groq.com/keys

---

## File Descriptions

| File | Purpose |
|------|---------|
| `startup1.bat` | Starts both backend and frontend in parallel |
| `verify-startup.bat` | Verifies all dependencies and performs setup |
| `.env` | Configuration file with API keys |
| `requirements.txt` | Python backend dependencies |
| `venv/` | Python virtual environment |
| `backend/` | FastAPI backend code |
| `frontend/` | React + Vite frontend code |

---

## Development Notes

### Backend Development
- Runs with `--reload` for hot reloading
- Changes to Python files auto-reload
- Check `backend/` folder for source code

### Frontend Development
- Vite provides hot module reloading
- Changes to React files auto-reload
- Check `frontend/src/` for source code

### API Integration
- Backend serves API at `http://localhost:8000`
- Frontend uses `http://localhost:8000` for API calls
- CORS is already configured for dev mode

---

## Next Steps

1. Run `startup1.bat` to start both servers
2. Open http://localhost:5173 in your browser
3. Login with test@gmail.com / test123
4. Start developing!

---

For more help, check the main [README.md](README.md)
