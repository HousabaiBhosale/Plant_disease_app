@echo off
cd /d "%~dp0"
echo Starting backend server on all network interfaces (0.0.0.0)...
echo This allows physical Android devices on the same WiFi to connect!
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
pause
