@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d %~dp0\..

REM Overzicht of man-page per script.
REM   scripts\h.cmd              -> korte catalogus
REM   scripts\h.cmd bootstrap    -> detail (man-page)
REM
REM Onderhoud: bij script toevoegen/wijzigen/verwijderen ook scripts\README.md
REM en deze file bijwerken. Echo-tekst: alleen eenvoudige ASCII (->, -).
REM Unicode-pijlen/em-dashes worden in Windows-cmd onleesbaar.

set "FILTER=%~1"
if /I "%FILTER%"=="-h" goto usage
if /I "%FILTER%"=="--help" goto usage

if not "%FILTER%"=="" (
  set "FILTER=!FILTER:scripts\=!"
  set "FILTER=!FILTER:.cmd=!"
)

if "%FILTER%"=="" goto catalog

if /I "%FILTER%"=="bootstrap" goto man_bootstrap
if /I "%FILTER%"=="check" goto man_check
if /I "%FILTER%"=="build-hugo" goto man_build_hugo
if /I "%FILTER%"=="serve-hugo" goto man_serve_hugo
if /I "%FILTER%"=="sync-bron-zondagen" goto man_sync
if /I "%FILTER%"=="h" goto man_help
if /I "%FILTER%"=="help" goto man_help

goto filter_list

:catalog
echo.
echo === VSA-demo scripts ===
echo Detail ^(man-page^): scripts\h.cmd ^<naam^>   bijv. scripts\h.cmd bootstrap
echo Begrippen + wanneer-wat: scripts\README.md
echo Groen voor commit ^(CI-spiegel^): scripts\check.cmd --strict
echo.
call :emit_short bootstrap "venv + catalogus (bron) + vsa-tool[rendering]" "-"
call :emit_short check "preflight / CI-spiegel" "--strict --external --skip-hugo"
call :emit_short build-hugo "volledige sitebuild + interne linkcheck" "-"
call :emit_short serve-hugo "lokale Hugo-preview" "--no-build"
call :emit_short sync-bron-zondagen "sync zondag-VSA uit bron" "[bron-root]"
call :emit_short h "catalogus of man-page per script" "[naam]"
echo.
echo Python-helpers ^(via .cmd^): validate_content.py, sync_bron_zondagen.py,
echo   update-nav-placeholders.py, check_hugo_links_and_assets.py,
echo   check_external_links.py
echo.
goto end_ok

:filter_list
set "ANY=0"
echo.
echo === VSA-demo scripts ^(filter: %FILTER%^) ===
echo Voor detail: scripts\h.cmd ^<exacte-naam^>   bijv. scripts\h.cmd bootstrap
echo.
call :try_short bootstrap "venv + catalogus (bron) + vsa-tool[rendering]" "-"
call :try_short check "preflight / CI-spiegel" "--strict --external --skip-hugo"
call :try_short build-hugo "volledige sitebuild + interne linkcheck" "-"
call :try_short serve-hugo "lokale Hugo-preview" "--no-build"
call :try_short sync-bron-zondagen "sync zondag-VSA uit bron" "[bron-root]"
call :try_short h "catalogus of man-page per script" "[naam]"
if "!ANY!"=="0" goto unknown
echo.
echo Meer uitleg: scripts\README.md
echo.
goto end_ok

:unknown
echo Geen script gevonden voor "%FILTER%".
echo Bekende namen: bootstrap, check, build-hugo, serve-hugo, sync-bron-zondagen, h
echo.
goto end_fail

:emit_short
echo scripts\%~1.cmd
echo   %~2
if not "%~3"=="-" echo   opties: %~3
echo   detail: scripts\h.cmd %~1
echo.
goto :eof

:try_short
echo %~1| findstr /I /C:"%FILTER%" >nul
if errorlevel 1 goto :eof
set "ANY=1"
call :emit_short %1 %2 %3
goto :eof

:usage
echo.
echo Gebruik:
echo   scripts\h.cmd              korte catalogus
echo   scripts\h.cmd ^<naam^>       man-page voor dat script
echo   scripts\h.cmd -h           deze uitleg
echo.
echo Voorbeelden:
echo   scripts\h.cmd bootstrap
echo   scripts\h.cmd check
echo.
echo Begrippen ^(preflight, CI-spiegel, ...^): scripts\README.md
echo.
goto end_ok

:man_bootstrap
echo.
echo NAME
echo   scripts\bootstrap.cmd
echo.
echo SYNOPSIS
echo   scripts\bootstrap.cmd
echo.
echo DESCRIPTION
echo   Eenmalige ^(of periodieke^) setup van de lokale Python-omgeving:
echo   - maakt .venv aan als die ontbreekt
echo   - installeert catalogus uit sibling ..\bron of vendor\bron
echo   - installeert vsa-tool[rendering] uit ..\VSA-tooling, vendor\, of GitHub
echo.
echo   Zonder bootstrap werken validate/generate en catalogus-includes niet
echo   ^(of niet met je lokale bron/tooling^).
echo.
echo WHEN
echo   Eerste checkout; na Python-upgrade; als vsa/catalogus-commando's ontbreken.
echo.
echo SEE ALSO
echo   scripts\h.cmd check
echo   scripts\README.md
echo.
goto end_ok

:man_check
echo.
echo NAME
echo   scripts\check.cmd - preflight / CI-spiegel
echo.
echo SYNOPSIS
echo   scripts\check.cmd [--strict] [--external] [--skip-hugo]
echo.
echo DESCRIPTION
echo   Draait lokaal de blocking pipeline die CI ook doet:
echo   sync zondag -^> validate -^> generate ^(md/svg/mxl^) -^> hugo -^> interne links.
echo.
echo   "Preflight" = check voor commit. "CI-spiegel" = met --strict dezelfde
echo   strengheid als GitHub Actions ^(ook VSA-warnings laten falen^).
echo.
echo OPTIONS
echo   --strict      faal ook op VSA-warnings ^(CI doet dit standaard^)
echo   --external    check ook externe http^(s^)-links ^(kan flaky zijn;
echo                 in CI is dit non-blocking, lokaal faalt het hard^)
echo   --skip-hugo   stop na sync + validate + generate ^(geen Hugo/linkcheck^)
echo.
echo WHEN
echo   Altijd voor committen/pushen: scripts\check.cmd --strict
echo   Tussendoor itereren op VSA: scripts\check.cmd --skip-hugo
echo.
echo SEE ALSO
echo   scripts\h.cmd serve-hugo
echo   scripts\README.md  ^(begrippen + CI-tabel^)
echo.
goto end_ok

:man_build_hugo
echo.
echo NAME
echo   scripts\build-hugo.cmd
echo.
echo SYNOPSIS
echo   scripts\build-hugo.cmd
echo.
echo DESCRIPTION
echo   Volledige sitebuild naar generated\site:
echo   sync -^> validate ^(met fail-on-warnings^) -^> generate -^> hugo -^> interne links.
echo   Vergelijkbaar met check.cmd --strict, bedoeld als expliciete "bouw de site".
echo.
echo   Commit geen generated\ of static\vsa\ - die mappen zijn build-output.
echo.
echo WHEN
echo   Als je een complete site-artifact wilt zonder serve; of om te vergelijken
echo   met CI-build. Voor preflight voor commit is check.cmd --strict genoeg.
echo.
echo SEE ALSO
echo   scripts\h.cmd check
echo   scripts\h.cmd serve-hugo
echo.
goto end_ok

:man_serve_hugo
echo.
echo NAME
echo   scripts\serve-hugo.cmd
echo.
echo SYNOPSIS
echo   scripts\serve-hugo.cmd [--no-build]
echo.
echo DESCRIPTION
echo   Start de Hugo-development server ^(http://localhost:1313/^).
echo   Standaard: eerst sync + validate + generate, daarna server.
echo   Met --no-build: alleen server; vereist bestaande generated\content
echo   ^(bijv. na een geslaagde check.cmd^).
echo.
echo OPTIONS
echo   --no-build   sla sync/validate/generate over; sneller herstarten
echo.
echo WHEN
echo   Content/layouts bekijken in de browser.
echo   Na check.cmd: scripts\serve-hugo.cmd --no-build
echo.
echo SEE ALSO
echo   scripts\h.cmd check
echo.
goto end_ok

:man_sync
echo.
echo NAME
echo   scripts\sync-bron-zondagen.cmd
echo.
echo SYNOPSIS
echo   scripts\sync-bron-zondagen.cmd [bron-root]
echo.
echo DESCRIPTION
echo   Kopieert tropaar/kondak ^(en gerelateerde^) zondag-bestanden uit de
echo   bron-repository naar content-source\praktijk\zondagen\.
echo   Zo blijft de demo synchroon met canonieke bron-VSA.
echo.
echo   Zonder argument: automatisch sibling ..\bron of vendor\bron.
echo   Met argument: expliciet pad naar een bron-checkout.
echo.
echo WHEN
echo   Handmatig als je bron net hebt bijgewerkt en alleen sync wilt.
echo   check.cmd / build-hugo / serve-hugo roepen sync zelf al aan.
echo.
echo SEE ALSO
echo   scripts\h.cmd check
echo   scripts\README.md  ^(begrip: Sync zondag^)
echo.
goto end_ok

:man_help
echo.
echo NAME
echo   scripts\h.cmd
echo.
echo SYNOPSIS
echo   scripts\h.cmd
echo   scripts\h.cmd ^<naam^>
echo   scripts\h.cmd -h
echo.
echo DESCRIPTION
echo   Zonder argument: korte catalogus van alle .cmd-scripts.
echo   Met exacte scriptnaam: man-page ^(doel, opties, wanneer^).
echo   Met onbekende/partiele tekst: gefilterde korte lijst, of foutmelding.
echo.
echo EXAMPLES
echo   scripts\h.cmd
echo   scripts\h.cmd bootstrap
echo   scripts\h.cmd check
echo.
echo SEE ALSO
echo   scripts\README.md  ^(begrippen, pipeline, CI-spiegel^)
echo.
goto end_ok

:end_ok
endlocal
exit /b 0

:end_fail
endlocal
exit /b 1
