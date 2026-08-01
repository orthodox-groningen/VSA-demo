@echo off
setlocal EnableExtensions
cd /d %~dp0\..

REM Preflight voor lokale commits: sync → validate → build → interne links.
REM Opties:
REM   --strict     fail ook op VSA-warnings
REM   --external   check ook externe http(s)-links (kan flaky zijn)
REM   --skip-hugo  stop na validate + markdown/svg/mxl (geen Hugo/linkcheck)

set "PY=python"
if exist .venv\Scripts\python.exe set "PY=.venv\Scripts\python.exe"

set "STRICT="
set "EXTERNAL="
set "SKIP_HUGO="

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--strict" set "STRICT=1" & shift & goto parse_args
if /I "%~1"=="--external" set "EXTERNAL=1" & shift & goto parse_args
if /I "%~1"=="--skip-hugo" set "SKIP_HUGO=1" & shift & goto parse_args
if /I "%~1"=="-h" goto usage
if /I "%~1"=="--help" goto usage
echo Onbekende optie: %~1
goto usage

:args_done

echo.
echo === VSA-demo check (preflight) ===
echo Python: %PY%
echo.

echo [1/6] Sync zondag bronbestanden
call scripts\sync-bron-zondagen.cmd
if errorlevel 1 exit /b 1
echo OK
echo.

echo [2/6] Validate content-source
if defined STRICT (
  "%PY%" scripts\validate_content.py --summary --fail-on-warnings content-source
) else (
  "%PY%" scripts\validate_content.py --summary content-source
)
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
"%PY%" scripts\update-nav-placeholders.py generated\content
if errorlevel 1 exit /b 1
echo OK
echo.

if defined SKIP_HUGO (
  echo [4/6] Hugo overgeslagen ^(--skip-hugo^)
  echo.
  echo Check OK tot en met generate ^(zonder Hugo/linkcheck^).
  endlocal
  exit /b 0
)

where hugo >nul 2>&1
if errorlevel 1 (
  echo ERROR: hugo not found on PATH.
  exit /b 1
)

echo [4/6] Build Hugo site
if exist generated\site rmdir /s /q generated\site
hugo ^
  --source . ^
  --contentDir generated\content ^
  --destination generated\site ^
  --baseURL /
if errorlevel 1 exit /b 1
echo OK
echo.

echo [5/6] Interne links en assets
"%PY%" scripts\check_hugo_links_and_assets.py --site-dir generated\site
if errorlevel 1 exit /b 1
echo OK
echo.

if defined EXTERNAL (
  echo [6/6] Externe http^(s^)-links
  "%PY%" scripts\check_external_links.py --site-dir generated\site
  if errorlevel 1 exit /b 1
  echo OK
  echo.
) else (
  echo [6/6] Externe links overgeslagen ^(gebruik --external om te checken^)
  echo.
)

echo Preflight OK.
endlocal
exit /b 0

:usage
echo.
echo Gebruik: scripts\check.cmd [--strict] [--external] [--skip-hugo]
echo.
echo   --strict      faal ook op VSA-warnings
echo   --external    check externe http^(s^)-links
echo   --skip-hugo   alleen sync + validate + generate
echo.
endlocal
exit /b 2
