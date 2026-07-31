@echo off
setlocal
cd /d %~dp0\..

set "PY=python"
if exist .venv\Scripts\python.exe set "PY=.venv\Scripts\python.exe"

echo.
echo === VSA-demo local preview ===
echo.

where hugo >nul 2>&1
if errorlevel 1 (
  echo ERROR: hugo not found on PATH.
  exit /b 1
)

echo [1/3] Validate content-source
"%PY%" -m vsa.cli validate content-source
if errorlevel 1 exit /b 1
echo.

echo [2/3] Generate Markdown + SVG
if exist generated\content rmdir /s /q generated\content
if exist static\vsa rmdir /s /q static\vsa
"%PY%" -m vsa.cli build-markdown ^
  content-source ^
  generated\content ^
  static\vsa ^
  --output-mode shortcode
if errorlevel 1 exit /b 1
"%PY%" scripts\update-nav-placeholders.py generated\content
if errorlevel 1 exit /b 1
echo.

echo [3/3] Start Hugo server
hugo server ^
  --source . ^
  --contentDir generated\content ^
  --baseURL / ^
  --disableFastRender ^
  --forceSyncStatic ^
  --noHTTPCache
endlocal
