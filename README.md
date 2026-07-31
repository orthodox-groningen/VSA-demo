# VSA-demo

Hugo-demo site voor [VSA-tooling](https://github.com/orthodox-groningen/VSA-tooling):
Markdown + VSA-notatie → SVG → statische site (GitHub Pages).

## Lokaal

Vereist sibling-checkouts (of `vendor/`) van **bron** en **VSA-tooling** voor catalogus-includes en zondag-sync:

```text
C:\Git\orthodox-groningen\
  bron\
  VSA-tooling\
  VSA-demo\
```

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

| Pad              | Rol                                              |
| ---------------- | ------------------------------------------------ |
| `content-source/`| Broncontent (bewerken), inclusief `lokaal/`      |
| `layouts/`       | Hugo-templates en shortcodes                     |
| `static/`        | CSS, favicons; gegenereerde SVG in `static/vsa/` |
| `scripts/`       | Bootstrap, sync, build, serve                    |
| `_deferred/`     | Uitgesteld: TEv2                                 |

## Afhankelijkheden

- Python ≥ 3.12
- Hugo ≥ 0.147
- `catalogus` uit [bron](https://github.com/orthodox-groningen/bron) (via bootstrap)
- `vsa-tool[rendering]` uit [VSA-tooling](https://github.com/orthodox-groningen/VSA-tooling)

## GitHub Pages

| Branch | Doel       | URL                                                      |
| ------ | ---------- | -------------------------------------------------------- |
| `main` | Productie  | https://orthodox-groningen.github.io/VSA-demo/           |
| andere | Preview    | https://orthodox-groningen.github.io/VSA-demo/preview/   |

Elke push triggert de workflow. Productie en preview delen branch `gh-pages` (map `preview/` blijft naast de root staan).

**Eenmalig in GitHub:** Settings → Pages → Source: **Deploy from a branch** → Branch: `gh-pages` → Folder: `/`.
