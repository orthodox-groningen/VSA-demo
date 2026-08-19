# Scripts (VSA-demo)

Deze map helpt je lokaal hetzelfde te controleren als GitHub Actions, zonder
dat je workflow-YAML hoeft te lezen. Na een tijdje niet aan de demo gewerkt te
hebben: begin hier of met `scripts\h.cmd`.

**Scripts vinden:** `scripts\h.cmd`  
Man-page per script: `scripts\h.cmd bootstrap`, `scripts\h.cmd check`, ...  
Deze README: begrippen, wanneer-wat, CI-spiegel.

## Onderhoudsafspraak (scripts)

Elke wijziging aan scripts hoort **in dezelfde wijziging** de docs bij te werken:

1. **Toevoegen** van een `.cmd` (of betekenisvolle helper) → vermelden in deze README
   (tabellen + eventueel begrip/situatie) **en** in `h.cmd` (catalogus + man-page).
2. **Verwijderen** → uit README en `h.cmd` halen.
3. **Wijzigen** van gedrag/opties → README en man-page in `h.cmd` aanpassen.

**ASCII in console-tekst:** alles wat `h.cmd` (en andere `.cmd`-scripts) met
`echo` op het scherm zetten, blijft **eenvoudige ASCII**. Geen Unicode-pijlen
(`→`), em-dashes (`—`), of andere tekens die in een Windows-cmd als rommel
verschijnen (`ΓåÆ`, enz.). Gebruik `->`, `-`, `...`.

Deze README mag normale Markdown/UTF-8 voor proza; in **commando-voorbeelden**
en pipeline-diagrammen liever dezelfde ASCII (`->`), zodat copy-paste naar cmd
schoon blijft.


## Begrippen

Korte woordenlijst voor termen die in scripts en docs terugkomen. (Dit is géén
vervanging van de org-glossary in bron — alleen script-/build-jargon.)

| Term              | Betekenis |
| ----------------- | --------- |
| **Preflight**     | Lokale check *vóór* je commit/push. Doel: dezelfde fouten vinden die CI anders op GitHub zou melden, zodat je niet heen-en-weer hoeft te fixen. In deze repo: vooral `scripts\check.cmd`. |
| **CI**            | *Continuous Integration* — geautomatiseerde checks op GitHub (hier: `.github/workflows/`). Bij een PR: `validate.yml`. Bij push: `pages.yml` (zelfde checks + deploy). |
| **CI-spiegel**    | Een lokaal commando dat de *blocking* CI-stappen nabootst. Als de spiegel groen is, mag je er redelijk op vertrouwen dat de workflow niet op dezelfde checks faalt. Spiegel hier: `scripts\check.cmd --strict`. |
| **Blocking**      | Check die de workflow rood maakt als hij faalt (sync, validate met warnings, generate, Hugo, interne links). |
| **Non-blocking**  | Check die wél draait maar de workflow niet faalt (`continue-on-error`). Hier: externe http(s)-links — die kunnen flaky zijn (netwerk, sites down). |
| **Strict**        | Optie `--strict` op `check.cmd`: faal ook op VSA-*warnings* (niet alleen errors). CI doet dit standaard (`--fail-on-warnings`). Zonder `--strict` zijn warnings lokaal toegestaan. |
| **Generate**      | `vsa build-markdown` + `vsa musicxml` + navigatie-placeholders: van `content-source/` naar `generated/content` en `static/vsa/`. Die mappen commit je niet. |
| **Sync (zondag)** | Kopieert tropaar/kondak-zondag uit de sibling-repo **bron** naar `content-source/praktijk/zondagen/`. Nodig zodat de demo actuele bronbestanden toont. |

## Wat wil je doen?

| Situatie | Commando |
| -------- | -------- |
| Eerste keer / na Python- of tool-update | `scripts\bootstrap.cmd` |
| “Welke scripts zijn er ook alweer?” | `scripts\h.cmd` |
| “Hoe werkt bootstrap precies?” | `scripts\h.cmd bootstrap` |
| Snel: VSA + generate, zonder Hugo | `scripts\check.cmd --skip-hugo` |
| Klaar om te committen (CI-spiegel) | `scripts\check.cmd --strict` |
| Zelfde + externe links meenemen | `scripts\check.cmd --strict --external` |
| Site lokaal bekijken (opnieuw bouwen) | `scripts\serve-hugo.cmd` |
| Site bekijken ná een geslaagde check | `scripts\serve-hugo.cmd --no-build` |
| Alleen zondagbestanden uit bron verversen | `scripts\sync-bron-zondagen.cmd` |

**Vuistregel:** groen vóór commit = `scripts\check.cmd --strict`.

## Testladder

Vaste volgorde: van snel/ruim naar streng (= CI). Eén gedeelde keten in
`_pipeline.cmd`; `check`, `build-hugo` en `serve-hugo` zijn dunne wrappers.

| Niveau | Commando | Wat het doet |
| ------ | -------- | ------------ |
| 0 setup | `scripts\bootstrap.cmd` | `.venv`, catalogus, vsa-tool |
| 1 snel | `scripts\check.cmd --skip-hugo` | sync + validate + generate |
| 2 preview | `scripts\serve-hugo.cmd --no-build` | hugo server (na niveau 3 of 4) |
| 3 preview+build | `scripts\serve-hugo.cmd` | sync + validate + generate + server |
| 4 CI-spiegel | `scripts\check.cmd --strict` | + hugo + interne links (blocking CI) |
| 5 + extern | `scripts\check.cmd --strict --external` | + externe links (non-blocking in CI) |
| 6 artifact | `scripts\build-hugo.cmd` | zelfde als niveau 4, output in `generated\site` |

Wanneer committen: minimaal **niveau 4** groen. Niveau 5 optioneel als je
externe links wilt meenemen.

## Pipeline (wat gebeurt er?)

```text
content-source/
    |
    +- sync-bron-zondagen     (zondag-VSA uit bron)
    +- validate               (vsa validate; met --strict ook warnings)
    +- build-markdown + mxl   (SVG/MXL -> static/vsa, md -> generated/content)
    +- update-nav-placeholders
    +- inject_git_dates + write_build_stamp (git_date per pagina; bouwtijd home)
    +- hugo                   (-> generated/site)
    +- link/asset-check       (interne links; optioneel externe)
```

Kern: [`_pipeline.cmd`](_pipeline.cmd) (niet direct aanroepen).

| Wrapper | Roept pipeline aan met |
| ------- | ---------------------- |
| `check.cmd` | `--strict` / `--skip-hugo` / `--external` via opties |
| `build-hugo.cmd` | altijd strict + hugo + interne links |
| `serve-hugo.cmd` | skip hugo (alleen generate), daarna `hugo server` |

`serve-hugo.cmd` valideert zonder `--strict` (snellere preview). Voor
CI-gelijkheid: eerst `check.cmd --strict`, daarna `serve-hugo.cmd --no-build`.

## CI ↔ lokaal (spiegel)

| CI (`validate.yml` / `pages.yml`)                                        | Lokaal                                  |
| ------------------------------------------------------------------------ | --------------------------------------- |
| sync + validate (`--fail-on-warnings`) + generate + hugo + interne links | `scripts\check.cmd --strict`            |
| externe http(s)-links (non-blocking in CI)                               | `scripts\check.cmd --strict --external` |
| sneller zonder Hugo/linkcheck                                            | `scripts\check.cmd --skip-hugo`         |

Verschillen om te onthouden:

- Lokaal zonder `--strict` mag je warnings zien zonder rode exitcode; CI niet.
- Externe links zijn in CI non-blocking; lokaal faalt `--external` wél hard als
  een link stuk is (handig om bewust te draaien, niet als enige preflight).
- CI checkt `bron` en `VSA-tooling` uit onder `vendor/`; lokaal gebruikt
  bootstrap bij voorkeur de sibling-mappen `..\bron` en `..\VSA-tooling`.

## Actieve scripts (`.cmd`)

| Script                   | Doel                                                         | Opties                                      |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------- |
| `h.cmd`                  | Catalogus of man-page per script                             | `[naam]` exact = detail; `-h`               |
| `bootstrap.cmd`          | `.venv` + catalogus (bron) + `vsa-tool[rendering]`           | —                                           |
| `check.cmd`              | Preflight / CI-spiegel (zie pipeline hierboven)              | `--strict` `--external` `--skip-hugo`       |
| `build-hugo.cmd`         | Volledige sitebuild (validate met warnings-fail) + linkcheck | —                                           |
| `serve-hugo.cmd`         | Lokale Hugo-preview                                          | `--no-build`                                |
| `sync-bron-zondagen.cmd` | Kopieer zondag-VSA uit bron naar `content-source`            | optioneel: pad naar bron-root               |

## Helper-scripts (Python)

Aangeroepen door de `.cmd`-wrappers. Handig als je één stap wilt debuggen;
voor dagelijks werk volstaan de `.cmd`-bestanden.

| Script                           | Doel                                        |
| -------------------------------- | ------------------------------------------- |
| `validate_content.py`            | `vsa validate` + optioneel fail-on-warnings |
| `sync_bron_zondagen.py`          | Zondag-sync uit bron                        |
| `update-nav-placeholders.py`     | Navigatie in `generated/content`            |
| `inject_git_dates.py`            | `git_date` in generated frontmatter         |
| `write_build_stamp.py`           | `data/build.yaml` (bouwtijd Amsterdam)      |
| `check_hugo_links_and_assets.py` | Interne links/assets in `generated/site`    |
| `check_external_links.py`        | Externe http(s)-links                       |
| `_pipeline.cmd`                  | Interne sync/validate/generate/hugo/links    |

## Typische volgorde

Eerste setup, daarna preflight, daarna preview zonder opnieuw te genereren:

```cmd
cd /d C:\Git\orthodox-ronl\VSA-demo
scripts\bootstrap.cmd
scripts\check.cmd --strict
scripts\serve-hugo.cmd --no-build
```

Open daarna http://localhost:1313/

## Zie ook

- Repo-README: [../README.md](../README.md) (structuur, Pages-URL’s)
- Workflows: [../.github/workflows/](../.github/workflows/)
- Org-terminologie (zangstuk, variant, …): [bron/docs/specs/terminologie.md](https://github.com/orthodox-ronl/bron/blob/main/docs/specs/terminologie.md)
