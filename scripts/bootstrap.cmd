@echo off
setlocal
cd /d %~dp0\..

set "PY=python"
if exist .venv\Scripts\python.exe set "PY=.venv\Scripts\python.exe"

echo.
echo === VSA-demo bootstrap ===
echo.

if not exist .venv (
  echo Creating .venv ...
  python -m venv .venv
  if errorlevel 1 exit /b 1
  set "PY=.venv\Scripts\python.exe"
)

echo Upgrading pip ...
"%PY%" -m pip install --upgrade pip
if errorlevel 1 exit /b 1

REM catalogus uit bron (sibling of vendor)
if exist vendor\bron\pyproject.toml (
  echo Installing catalogus from vendor\bron ...
  "%PY%" -m pip install -e vendor\bron
  if errorlevel 1 exit /b 1
) else if exist ..\bron\pyproject.toml (
  echo Installing catalogus from ..\bron ...
  "%PY%" -m pip install -e ..\bron
  if errorlevel 1 exit /b 1
) else (
  echo WARNING: bron niet gevonden ^(vendor\bron of ..\bron^).
  echo          Catalogus-includes ^(id:/zoek=/bron:^) werken dan niet.
)

REM vsa-tool: editable sibling/vendor zodat discover_bron_root sibling bron vindt
if exist vendor\VSA-tooling\pyproject.toml (
  echo Installing vsa-tool[rendering] from vendor\VSA-tooling ...
  "%PY%" -m pip install -e "vendor\VSA-tooling[rendering]"
  if errorlevel 1 exit /b 1
) else if exist ..\VSA-tooling\pyproject.toml (
  echo Installing vsa-tool[rendering] from ..\VSA-tooling ...
  "%PY%" -m pip install -e "..\VSA-tooling[rendering]"
  if errorlevel 1 exit /b 1
) else (
  echo Installing vsa-tool[rendering] from GitHub main ...
  "%PY%" -m pip install "vsa-tool[rendering] @ git+https://github.com/orthodox-groningen/VSA-tooling.git@main"
  if errorlevel 1 exit /b 1
  echo NOTE: zonder lokale VSA-tooling-checkout vindt id:-resolutie mogelijk geen bron.
)

echo.
echo Bootstrap complete.
echo Run: scripts\check.cmd --strict
echo      scripts\serve-hugo.cmd --no-build
endlocal
