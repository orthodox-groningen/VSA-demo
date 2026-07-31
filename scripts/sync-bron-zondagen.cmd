@echo off
setlocal
cd /d %~dp0\..

set "PY=python"
if exist .venv\Scripts\python.exe set "PY=.venv\Scripts\python.exe"

if not "%~1"=="" (
  "%PY%" scripts\sync_bron_zondagen.py --bron-root %~1
  exit /b %ERRORLEVEL%
)

"%PY%" scripts\sync_bron_zondagen.py
endlocal
