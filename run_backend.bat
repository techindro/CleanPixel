@echo off
title CleanPixel AI Backend Server
echo ===================================================
echo        CLEANPIXEL AI - LOCAL BACKEND SERVER
echo ===================================================
echo Starting FastAPI neural inpainting server on port 8000...
cd /d "%~dp0backend"
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
pause
