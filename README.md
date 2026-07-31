# VSA-demo

Hugo-demo site voor [VSA-tooling](https://github.com/orthodox-groningen/VSA-tooling):
Markdown + VSA-notatie → SVG → statische site (GitHub Pages).

## Lokaal

```cmd
cd /d C:\Git\orthodox-groningen\VSA-demo
scripts\bootstrap.cmd
scripts\serve-hugo.cmd
```

Open daarna http://localhost:1313/

Volledige build:

```cmd
scripts\build-hugo.cmd
```

## Structuur

| Pad | Rol |
| --- | --- |
| `content-source/` | Broncontent (bewerken) |
| `layouts/` | Hugo-templates en shortcodes |
| `static/` | CSS, favicons; gegenereerde SVG in `static/vsa/` |
| `scripts/` | Bootstrap, build, serve |
| `_deferred/` | Uitgestelde onderdelen (o.a. TEv2) |

## Afhankelijkheden

- Python ≥ 3.12
- Hugo ≥ 0.147
- `vsa-tool[rendering]` (via `scripts\bootstrap.cmd`)

## GitHub Pages

Push naar `main` (of handmatig **Actions → Deploy site to GitHub Pages**) bouwt en publiceert naar branch `gh-pages`.

**Eenmalig in GitHub:** Settings → Pages → Source: **Deploy from a branch** → Branch: `gh-pages` → Folder: `/`.

URL: https://orthodox-groningen.github.io/VSA-demo/
