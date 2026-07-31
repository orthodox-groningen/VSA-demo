# Uitgesteld tot na de eerste Pages-publicatie

Onderdelen die **niet** in de minimale build-pipeline zitten:

| Map | Inhoud |
| --- | ------ |
| `tev2/` | TEv2-config, glossaries, terminologie-stubs |
| `content-needs-bron/` | Pagina's met `:::include` naar bron/catalogus of ontbrekende gesyncte `.vsa` |
| `content-pending/` | Zelfde klasse content, geparkeerd voor herintegratie |

Herintegratie later: bron-checkout + sync/catalogus in CI, daarna content terug naar `content-source/`.
