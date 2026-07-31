"""Materialiseer zondag-zangstukken uit bron-checkout naar content-source.

Schrijft alleen binaire bronassets (.vsa, .jpg, .coria.html), geen markdown.
Spiegel van VSA-tooling/scripts/sync_bron_zondagen.py (outputpad aangepast).
"""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parents[1]

# (bron scan-bestandsnaam, VSA-demo outputnaam)
MELODIE_EXPORT: dict[int, tuple[str, str]] = {
    1: ("koormap.jpg", "tropaarmelodie-toon-1.jpg"),
    2: ("koormap.jpg", "tropaarmelodie-toon-2.jpg"),
    3: ("koormap.jpg", "tropaarmelodie-toon-3.jpg"),
    4: ("koormap.jpg", "tropaarmelodie-toon-4.jpg"),
    5: ("koormap-5.jpg", "tropaarmelodie-toon-5.jpg"),
    6: ("koormap.jpg", "tropaarmelodie-toon-6.jpg"),
    7: ("koormap.jpg", "tropaarmelodie-toon-7.jpg"),
    8: ("koormap.jpg", "tropaarmelodie-toon-8.jpg"),
}

ZANGSTUK_PREFIXES = (
    "troparion-zondag-toon-",
    "kondak-zondag-toon-",
    "troparion-melodie-toon-",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Sync zondag-zangstukken uit bron-repo naar content-source.",
    )
    parser.add_argument(
        "--bron-root",
        type=Path,
        default=None,
        help="Pad naar bron-checkout (default: vendor/bron of sibling ../bron).",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="Doelmap (default: content-source/praktijk/zondagen).",
    )
    parser.add_argument(
        "--tones",
        type=int,
        nargs="*",
        default=None,
        metavar="N",
        help="Alleen deze tonen (1–8); default alle.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Toon acties zonder te kopiëren.",
    )
    return parser.parse_args()


def _load_tone(zangstuk_dir: Path) -> int:
    yaml_path = zangstuk_dir / "zangstuk.yaml"
    data = yaml.safe_load(yaml_path.read_text(encoding="utf-8"))
    tone = data.get("toon")
    if tone is None:
        tone = data.get("tone")  # verouderd; bron gebruikt canoniek `toon`
    if tone is None:
        raise ValueError(f"Geen toon in {yaml_path}")
    return int(tone)


def _copy(src: Path, dst: Path, dry_run: bool) -> None:
    if not src.is_file():
        raise FileNotFoundError(f"Bronbestand ontbreekt: {src}")
    if dry_run:
        print(f"  copy {src} -> {dst}")
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def sync_troparion(zangstuk_dir: Path, tone: int, output_dir: Path, dry_run: bool) -> int:
    count = 0
    vsa_src = zangstuk_dir / "sources" / "vsa" / "groningen.vsa"
    vsa_dst = output_dir / f"tropaar-zondag-toon-{tone}.vsa"
    _copy(vsa_src, vsa_dst, dry_run)
    count += 1

    coria_src = zangstuk_dir / "sources" / "vsa" / "groningen.coria.html"
    if coria_src.is_file():
        coria_dst = output_dir / f"tropaar-zondag-toon-{tone}.coria.html"
        _copy(coria_src, coria_dst, dry_run)
        count += 1
    return count


def sync_kondak(zangstuk_dir: Path, tone: int, output_dir: Path, dry_run: bool) -> int:
    vsa_src = zangstuk_dir / "sources" / "vsa" / "groningen.vsa"
    vsa_dst = output_dir / f"kondak-zondag-toon-{tone}.vsa"
    _copy(vsa_src, vsa_dst, dry_run)
    return 1


def sync_melodie(zangstuk_dir: Path, tone: int, output_dir: Path, dry_run: bool) -> int:
    scan_name, output_name = MELODIE_EXPORT[tone]
    jpg_src = zangstuk_dir / "sources" / "scan" / scan_name
    jpg_dst = output_dir / output_name
    _copy(jpg_src, jpg_dst, dry_run)
    return 1


def sync_zangstuk(
    zangstuk_dir: Path,
    output_dir: Path,
    tones: set[int] | None,
    dry_run: bool,
) -> int:
    zangstuk_id = zangstuk_dir.name
    if not zangstuk_id.startswith(ZANGSTUK_PREFIXES):
        return 0

    tone = _load_tone(zangstuk_dir)
    if tones is not None and tone not in tones:
        return 0

    print(f"{zangstuk_id} (toon {tone})")

    if zangstuk_id.startswith("troparion-zondag-toon-"):
        return sync_troparion(zangstuk_dir, tone, output_dir, dry_run)
    if zangstuk_id.startswith("kondak-zondag-toon-"):
        return sync_kondak(zangstuk_dir, tone, output_dir, dry_run)
    if zangstuk_id.startswith("troparion-melodie-toon-"):
        return sync_melodie(zangstuk_dir, tone, output_dir, dry_run)
    return 0


def resolve_bron_root(explicit: Path | None = None) -> Path:
    if explicit is not None:
        return explicit.resolve()

    for candidate in (REPO_ROOT / "vendor" / "bron", REPO_ROOT.parent / "bron"):
        if (candidate / "zangstukken").is_dir():
            return candidate.resolve()

    print(
        "Fout: bron-repo niet gevonden. Checkout naar vendor/bron, "
        "gebruik sibling ../bron, of geef --bron-root op.",
        file=sys.stderr,
    )
    raise SystemExit(1)


def main() -> int:
    args = parse_args()
    bron_root = resolve_bron_root(args.bron_root)
    zangstukken_dir = bron_root / "zangstukken"

    if not zangstukken_dir.is_dir():
        print(f"Fout: {zangstukken_dir} bestaat niet.", file=sys.stderr)
        return 1

    if args.output_dir is None:
        output_dir = REPO_ROOT / "content-source" / "praktijk" / "zondagen"
    else:
        output_dir = args.output_dir.resolve()

    tones = set(args.tones) if args.tones else None
    total = 0

    for zangstuk_dir in sorted(zangstukken_dir.iterdir()):
        if not zangstuk_dir.is_dir():
            continue
        if not (zangstuk_dir / "zangstuk.yaml").is_file():
            continue
        total += sync_zangstuk(zangstuk_dir, output_dir, tones, args.dry_run)

    print(
        f"Klaar: {total} bestand(en) "
        f"{'zouden worden ' if args.dry_run else ''}"
        f"gekopieerd naar {output_dir}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
