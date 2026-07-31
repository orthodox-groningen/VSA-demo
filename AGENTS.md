# AGENTS.md

Richtlijnen voor AI-assistenten in
[orthodox-groningen/VSA-tooling](https://github.com/orthodox-groningen/VSA-tooling).

Organisatie-context (andere repo's, terminologie): zie
[bron/AGENTS.md](https://github.com/orthodox-groningen/bron/blob/main/AGENTS.md).

---

## Projectoverzicht

VSA-tooling is de **Python-toolchain** voor Vereenvoudigde Slavische Accentnotatie:

- parser en semantische validator;
- CLI (`vsa`): validate, parse, blocks, build-markdown, svg, musicxml, …;
- vsa-demo (`examples/vsa-demo/`) als integratie- en documentatievoorbeeld;
- regressietests en GitHub Actions CI (inclusief herbruikbare render-workflow).

**Normatieve org-specs staan in `bron`** — link ernaar, dupliceer niet. Tool-specifieke
documentatie hoort in `docs/spec/` en `docs/architecture/`.

---

## Terminologie (orthodox-groningen)
 
Normatieve glossary:
[bron/docs/specs/terminologie.md](https://github.com/orthodox-groningen/bron/blob/main/docs/specs/terminologie.md)

Vier niveaus: `zangstuk-id` → `variant-id` → `uitvoeringsvorm-id` → `representatie-id`

Regels R1–R5 en documentatie-eigendom: zie
[documentatie-eigendom](https://github.com/orthodox-groningen/bron/blob/main/docs/specs/documentatie-eigendom.md)
en `.cursor/rules/orthodox-groningen-terminologie.mdc`.

**Vermijden:** `uv-id`, afkorting `uv`, **uitvoeringsalternatief**, impliciet `variant-id: standaard`.

---

## LLM Coding Guidelines

<!-- Gebaseerd op https://github.com/multica-ai/andrej-karpathy-skills -->

Gedragsrichtlijnen om veelvoorkomende LLM-fouten te verminderen. Bij triviale taken: gebruik je oordeel.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Match existing style, even if you'd do it differently.
- Remove orphans only from **your** changes; don't delete pre-existing dead code unless asked.

### 4. Goal-Driven Execution

Define verifiable success criteria (tests, validate, build) and loop until they pass.

---

## Ontwikkelomgeving

| Vereiste | Versie / tool                                                                     |
| -------- | --------------------------------------------------------------------------------- |
| Python   | ≥ 3.12                                                                            |
| venv     | `.venv` (via bootstrap)                                                           |
| Tests    | pytest                                                                            |
| Hugo     | 0.147.9 (CI; lokaal voor demo-build)                                              |
| bron     | checkout onder `vendor/bron` of sibling `../bron` (CI/sync; **catalogus**-pakket) |

```cmd
cd /d C:\Git\orthodox-groningen\VSA-tooling
scripts\bootstrap.cmd
```

`bootstrap.cmd` installeert **catalogus** uit `vendor\bron` of `..\bron` vóór `vsa-tool`.

**Rendering (SVG):** `pip install -r requirements-rendering.txt` (Pillow, DejaVu in `assets/fonts/`).

**Commando's voor de gebruiker:** één kopieerbaar cmd-blok, Windows-paden (`\`), begin met `cd /d`.

---

## Build, lint en test

### Tests

```cmd
cd /d C:\Git\orthodox-groningen\VSA-tooling
scripts\test.cmd
```

Verbose: `scripts\test-verbose.cmd`

### Volledige CI lokaal

```cmd
cd /d C:\Git\orthodox-groningen\VSA-tooling
scripts\ci.cmd
```

Stappen: pytest → sync zondag-bronbestanden → `vsa validate examples\vsa-demo\content-source`
→ `vsa build-markdown` naar `generated\ci\`.

### VSA CLI (typisch)

```cmd
cd /d C:\Git\orthodox-groningen\VSA-tooling
call .venv\Scripts\activate
vsa validate examples\vsa-demo\content-source
vsa build-markdown examples\vsa-demo\content-source generated\hugo\content examples\vsa-demo\static\vsa
```

### vsa-demo

```cmd
cd /d C:\Git\orthodox-groningen\VSA-tooling
scripts\build-hugo.cmd
scripts\serve-hugo.cmd
```

Opruimen: `scripts\clean.cmd`. Overzicht scripts: `scripts/README.md`.

---

## Architectuur

```
src/vsa/              # parser, validator, renderers, CLI
tests/                # pytest
examples/minimal|regression|edge-cases|vsa-demo/
docs/spec/            # VSA-syntax (canoniek in deze repo)
docs/architecture/    # ontwerpbeslissingen
generated/            # build-output — niet handmatig redigeren
vendor/bron/          # bron-checkout (CI)
```

Specificatie: `docs/spec/vsa-spec-v1.md`. vsa-demo structuur: `docs/hugo-site-structure.md`.

### Belangrijke grenzen

- Scripts mogen **`examples\vsa-demo\content-source` niet redactioneel herschrijven**.
- Wijzig normatieve terminologie via PR op **bron**, niet in stubs hier.
- Afgeleide output hoort in `generated/` of `static/vsa`, niet in `bron`.

---

## Git commits

[Conventional Commits](https://www.conventionalcommits.org/). Typische scopes: `vsa`, `parser`, `svg`, `hugo`, `ci`, `docs`.

```
feat(vsa): voeg MusicXML-export voor compound-melisma toe
test(parser): regressie voor height-marker policy
```

**Maak alleen commits wanneer de gebruiker dat expliciet vraagt.**

---

## Pull requests

Gebruik **`gh` CLI**. Stel titel, body en `gh pr create`-commando **voor aan de gebruiker** vóór uitvoering.

```cmd
cd /d C:\Git\orthodox-groningen\VSA-tooling
git push -u origin HEAD
gh pr create --title "feat(vsa): korte beschrijving" --body "## Summary
- …

## Test plan
- [ ] vsa validate examples\vsa-demo\content-source
- [ ] scripts\test.cmd
"
```

---

## CI/CD

Overzicht **wanneer welke workflow** draait: [.github/workflows/README.md](.github/workflows/README.md).

| Workflow                    | Doel                                                |
| --------------------------- | --------------------------------------------------- |
| `vsa-ci.yml`                | Windows: `scripts\ci.cmd` (pytest, validate, build) |
| `site-build.yml`            | Linux: pytest, sync bron, validate, Hugo-build      |
| `pages-preview.yml`         | GitHub Pages preview (elke push, alle branches)     |
| `pages-demo.yml`            | Demo-site publicatie (handmatig)                    |
| `release-artifacts.yml`     | Release-package + demo-artifact (handmatig)         |
| `pages-deploy-reusable.yml` | Herbruikbare Pages-deploy voor org-repo's           |
| `vsa-render-reusable.yml`   | Herbruikbaar VSA-renderen voor andere org-repo's    |

CI checkt `bron` uit naar `vendor/bron` (`ref: main`).

---

## Cursor-regels

| Regel                                 | Doel                             |
| ------------------------------------- | -------------------------------- |
| `orthodox-groningen-terminologie.mdc` | Glossary + R1–R5                 |
| `copy-pasteable-cli-commands.mdc`     | cmd-blokken voor gebruiker       |
| `markdown-table-layout.mdc`           | Tabel-alignment in markdown-bron |

Na bulk-tabellen: `python scripts/align_markdown_tables.py <pad>`.

---

## Extern hergebruik

```cmd
python -m pip install "vsa-tool[rendering] @ git+https://github.com/orthodox-groningen/VSA-tooling.git@main"
```

Zie `docs/reuse-vsa-tooling.md`.
