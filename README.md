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

Scripts vinden: `scripts\h.cmd` · detail per script: `scripts\h.cmd bootstrap` — zie [scripts/README.md](scripts/README.md).

Open daarna http://localhost:1313/

Na een geslaagde `scripts\check.cmd` kun je zonder opnieuw te genereren serveren:

```cmd
scripts\serve-hugo.cmd --no-build
```

Volledige build (inclusief interne linkcheck):

```cmd
scripts\build-hugo.cmd
```

Preflight vóór een commit (groen = CI-blocking checks):

```cmd
cd /d C:\Git\orthodox-groningen\VSA-demo
scripts\check.cmd --strict
scripts\check.cmd --strict --external
```

| Optie         | Effect                                              |
| ------------- | --------------------------------------------------- |
| `--strict`    | Faal ook op VSA-warnings                            |
| `--external`  | Check externe `http(s)`-links (kan flaky zijn)      |
| `--skip-hugo` | Alleen sync + validate + generate (sneller)         |

## Structuur

| Pad               | Rol                                              |
| ----------------- | ------------------------------------------------ |
| `content-source/` | Broncontent (bewerken), inclusief `lokaal/`      |
| `layouts/`        | Hugo-templates en shortcodes                     |
| `static/`         | CSS, favicons; gegenereerde SVG in `static/vsa/` |
| `scripts/`        | Bootstrap, sync, build, check, serve             |
| `_deferred/`      | Uitgesteld: TEv2                                 |

## Afhankelijkheden

- Python ≥ 3.12
- Hugo ≥ 0.147
- `catalogus` uit [bron](https://github.com/orthodox-groningen/bron) (via bootstrap)
- `vsa-tool[rendering]` uit [VSA-tooling](https://github.com/orthodox-groningen/VSA-tooling)

## CI-checks

| Workflow        | Wanneer          | Blocking                                                         | Niet-blocking        |
| --------------- | ---------------- | ---------------------------------------------------------------- | -------------------- |
| `validate.yml`  | pull request     | sync, validate (+warnings), generate, hugo, interne links/assets | externe links        |
| `pages.yml`     | push / handmatig | hetzelfde + deploy naar `gh-pages`                               | externe links        |

## GitHub Pages

| Branch | Doel       | URL                                                      |
| ------ | ---------- | -------------------------------------------------------- |
| `main` | Productie  | https://orthodox-groningen.github.io/VSA-demo/           |
| andere | Preview    | https://orthodox-groningen.github.io/VSA-demo/preview/   |

Elke push triggert de workflow. Productie en preview delen branch `gh-pages` (map `preview/` blijft naast de root staan).

**Eenmalig in GitHub:** Settings → Pages → Source: **Deploy from a branch** → Branch: `gh-pages` → Folder: `/`.
