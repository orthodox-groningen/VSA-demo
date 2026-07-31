# AGENTS.md — VSA-demo

Richtlijnen voor AI-assistenten in deze repository (demo-/publicatiesite voor VSA).

Organisatie-context: [bron/AGENTS.md](https://github.com/orthodox-groningen/bron/blob/main/AGENTS.md).
Toolchain: [VSA-tooling](https://github.com/orthodox-groningen/VSA-tooling).

---

## Rol van deze repo

**VSA-demo** is een Hugo-site die laat zien hoe `vsa-tool` in een publicatiepipeline
wordt gebruikt (model voor toekomstige parochie-sites).

| Onderdeel | Pad |
| --------- | --- |
| Bewerkbare bron | `content-source/` |
| Hugo-templates | `layouts/` |
| Statische assets | `static/` (SVG’s in `static/vsa/` zijn gegenereerd) |
| Build-scripts | `scripts/` |
| Gegenereerd | `generated/` (niet committen) |

Normatieve org-specs staan in **bron** — link, niet dupliceren.

---

## Terminologie

[bron/docs/specs/terminologie.md](https://github.com/orthodox-groningen/bron/blob/main/docs/specs/terminologie.md)

`zangstuk-id` → `variant-id` → `uitvoeringsvorm-id` → `representatie-id`

Vermijd: `uv-id`, afkorting `uv`, **uitvoeringsalternatief**, impliciet `variant-id: standaard`.

---

## Lokaal bouwen

```cmd
cd /d C:\Git\orthodox-groningen\VSA-demo
scripts\bootstrap.cmd
scripts\build-hugo.cmd
scripts\serve-hugo.cmd
```

`bootstrap.cmd` installeert `vsa-tool[rendering]` vanaf VSA-tooling `main`.

---

## Pipeline

```text
content-source  --vsa validate-->
                --vsa build-markdown-->  generated/content + static/vsa
                --update-nav-placeholders-->
                --hugo-->                generated/site
```

---

## Git / commits

Conventional Commits. Alleen committen als de gebruiker dat vraagt.
