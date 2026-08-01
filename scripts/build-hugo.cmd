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

echo [1/6] Sync zondag bronbestanden
call scripts\sync-bron-zondagen.cmd
if errorlevel 1 exit /b 1
echo OK
echo.

echo [2/6] Validate content-source
"%PY%" scripts\validate_content.py --summary --fail-on-warnings content-source
if errorlevel 1 exit /b 1
echo OK
echo.

echo [3/6] Generate Markdown + SVG + MusicXML
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

echo [4/6] Update navigation placeholders
"%PY%" scripts\update-nav-placeholders.py generated\content
if errorlevel 1 exit /b 1
echo OK
echo.

echo [5/6] Build Hugo site
if exist generated\site rmdir /s /q generated\site
hugo ^
  --source . ^
  --contentDir generated\content ^
  --destination generated\site ^
  --baseURL /
if errorlevel 1 exit /b 1
echo OK
echo.

echo [6/6] Interne links en assets
"%PY%" scripts\check_hugo_links_and_assets.py --site-dir generated\site
if errorlevel 1 exit /b 1
echo OK
echo.

echo Build complete: generated\site
endlocal
