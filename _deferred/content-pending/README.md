# Uitgestelde content (Stap 1)

Deze pagina's horen bij de demo maar blokkeerden de eerste schone build omdat ze afhangen van:

- `:::include … zoek=…` / catalogus-zoek tegen `bron`
- gesynchroniseerde `.vsa` uit `bron` (zondag-toon-*)
- `lokaal/`-structuur of `bron:`-includes

Later terugzetten wanneer sync/`vendor/bron` en eventueel `lokaal/` in de pipeline zitten.
