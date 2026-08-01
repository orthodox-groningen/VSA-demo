@echo off
setlocal EnableExtensions
cd /d %~dp0\..

REM Start lokale Hugo-preview.
REM   --no-build   sla sync/validate/generate over; gebruik bestaande
REM                generated\content en static\vsa (bijv. na scripts\check.cmd)

set "PY=python"
if exist .venv\Scripts\python.exe set "PY=.venv\Scripts\python.exe"

set "NO_BUILD="

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--no-build" set "NO_BUILD=1" & shift & goto parse_args
if /I "%~1"=="-h" goto usage
if /I "%~1"=="--help" goto usage
echo Onbekende optie: %~1
goto usage

:args_done

echo.
echo === VSA-demo local preview ===
echo.

where hugo >nul 2>&1
if errorlevel 1 (
  echo ERROR: hugo not found on PATH.
  exit /b 1
)

if defined NO_BUILD (
  if not exist generated\content (
    echo ERROR: generated\content ontbreekt. Draai eerst scripts\check.cmd
    echo        of scripts\serve-hugo.cmd zonder --no-build.
    exit /b 1
  )
  echo [1/1] Generate overgeslagen ^(--no-build^); start Hugo server
  echo.
  goto start_server
)

echo [1/3] Sync zondag bronbestanden
call scripts\sync-bron-zondagen.cmd
if errorlevel 1 exit /b 1
echo.

echo [2/3] Validate + generate Markdown/SVG/MusicXML
"%PY%" -m vsa.cli validate content-source
if errorlevel 1 exit /b 1
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
"%PY%" scripts\update-nav-placeholders.py generated\content
if errorlevel 1 exit /b 1
echo.

echo [3/3] Start Hugo server
:start_server
hugo server ^
  --source . ^
  --contentDir generated\content ^
  --baseURL / ^
  --disableFastRender ^
  --forceSyncStatic ^
  --noHTTPCache
endlocal
exit /b %ERRORLEVEL%

:usage
echo.
echo Gebruik: scripts\serve-hugo.cmd [--no-build]
echo.
echo   --no-build   geen sync/validate/generate; alleen hugo server
echo                ^(vereist bestaande generated\content^)
echo.
endlocal
exit /b 2
