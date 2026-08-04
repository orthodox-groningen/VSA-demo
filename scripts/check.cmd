@echo off
setlocal EnableExtensions
cd /d %~dp0\..

REM Preflight / CI-spiegel. Zie scripts\README.md (testladder).

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

if defined STRICT set "PIPELINE_STRICT=1"
if defined EXTERNAL set "PIPELINE_EXTERNAL=1"
if defined SKIP_HUGO set "PIPELINE_SKIP_HUGO=1"
set "PIPELINE_TITLE=VSA-demo check (preflight)"

call scripts\_pipeline.cmd
exit /b %ERRORLEVEL%

:usage
echo.
echo Gebruik: scripts\check.cmd [--strict] [--external] [--skip-hugo]
echo.
echo   --strict      faal ook op VSA-warnings ^(CI-spiegel^)
echo   --external    check externe http^(s^)-links
echo   --skip-hugo   alleen sync + validate + generate
echo.
echo Detail: scripts\h.cmd check
echo.
endlocal
exit /b 2
