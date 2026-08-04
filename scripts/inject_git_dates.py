"""Inject git_date frontmatter into generated Hugo content from content-source history."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_GENERATED = REPO_ROOT / "generated" / "content"
DEFAULT_SOURCE = REPO_ROOT / "content-source"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Zet git_date (YYYY-MM-DD) in generated markdown frontmatter.",
    )
    parser.add_argument(
        "generated_root",
        nargs="?",
        default=str(DEFAULT_GENERATED),
        help="Gegenereerde Hugo-content (default: generated/content).",
    )
    parser.add_argument(
        "source_root",
        nargs="?",
        default=str(DEFAULT_SOURCE),
        help="Bron-content voor git log (default: content-source).",
    )
    return parser.parse_args()


def git_last_commit_date(path: Path, repo_root: Path) -> str | None:
    if not path.is_file():
        return None
    result = subprocess.run(
        ["git", "log", "-1", "--format=%as", "--", str(path)],
        capture_output=True,
        text=True,
        cwd=str(repo_root),
    )
    date_iso = result.stdout.strip()
    return date_iso or None


def set_frontmatter_field(content: str, key: str, value: str) -> str:
    if content.startswith("---\n"):
        end = content.find("\n---\n", 4)
        if end == -1:
            return content
        fm_lines = content[4:end].splitlines()
        body = content[end + 5 :]
        fm_lines = [line for line in fm_lines if not line.startswith(f"{key}:")]
        fm_lines.append(f"{key}: {value}")
        return "---\n" + "\n".join(fm_lines) + "\n---\n" + body
    return f"---\n{key}: {value}\n---\n\n" + content


def main() -> int:
    args = parse_args()
    generated_root = Path(args.generated_root)
    source_root = Path(args.source_root)

    if not generated_root.is_dir():
        print(f"Niet gevonden: {generated_root}", file=sys.stderr)
        return 1
    if not source_root.is_dir():
        print(f"Niet gevonden: {source_root}", file=sys.stderr)
        return 1

    count = 0
    for md_file in sorted(generated_root.rglob("*.md")):
        rel = md_file.relative_to(generated_root)
        source_file = source_root / rel
        date_iso = git_last_commit_date(source_file, REPO_ROOT)
        if not date_iso:
            continue
        original = md_file.read_text(encoding="utf-8")
        updated = set_frontmatter_field(original, "git_date", date_iso)
        if updated != original:
            md_file.write_text(updated, encoding="utf-8")
            count += 1

    print(f"git_date geinjecteerd in {count} bestand(en).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
