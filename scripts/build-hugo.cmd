@echo off
setlocal
cd /d %~dp0\..

set "PY=python"
if exist .venv\Scripts\python.exe set "PY=.venv\Scripts\python.exe"

echo.
echo === VSA-demo build ===
echo Python: %PY%
echo.

where hugo >nul 2>&1
if errorlevel 1 (
  echo ERROR: hugo not found on PATH.
  exit /b 1
)

echo [1/5] Sync zondag bronbestanden
call scripts\sync-bron-zondagen.cmd
if errorlevel 1 exit /b 1
echo OK
echo.

echo [2/5] Validate content-source
"%PY%" -m vsa.cli validate content-source
if errorlevel 1 exit /b 1
echo OK
echo.

echo [3/5] Generate Markdown + SVG + MusicXML
if exist generated\content rmdir /s /q generated\content
if exist static\vsa rmdir /s /q static\vsa
"%PY%" -m vsa.cli build-markdown ^
  content-source ^
  generated\content ^
  static\vsa ^
  --output-mode shortcode
if errorlevel 1 exit /b 1
"%PY%" -m vsa.cli musicxml ^
  content-source ^
  static\vsa\mxl
if errorlevel 1 exit /b 1
echo OK
echo.

echo [4/5] Update navigation placeholders
"%PY%" scripts\update-nav-placeholders.py generated\content
if errorlevel 1 exit /b 1
echo OK
echo.

echo [5/5] Build Hugo site
if exist generated\site rmdir /s /q generated\site
hugo ^
  --source . ^
  --contentDir generated\content ^
  --destination generated\site ^
  --baseURL /
if errorlevel 1 exit /b 1

echo.
echo Build complete: generated\site
endlocal
