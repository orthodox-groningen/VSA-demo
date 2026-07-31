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

echo Installing vsa-tool[rendering] from VSA-tooling@main ...
"%PY%" -m pip install --upgrade pip
"%PY%" -m pip install "vsa-tool[rendering] @ git+https://github.com/orthodox-groningen/VSA-tooling.git@main"
if errorlevel 1 exit /b 1

echo.
echo Bootstrap complete.
echo Run: scripts\build-hugo.cmd
echo      scripts\serve-hugo.cmd
endlocal
