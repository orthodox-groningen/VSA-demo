from __future__ import annotations

from pathlib import Path
import argparse
import os
import re


MARKER_RE = re.compile(r"<!--\s*VSA-NAV:(HOME|UP|SIBLINGS|CHILDREN|PAGES|PAGES-HERE)\s*-->")
GENERATED_BLOCK_RE_TEMPLATE = (
    r"<!--\s*VSA-NAV-GENERATED:{kind}-START\s*-->"
    r".*?"
    r"<!--\s*VSA-NAV-GENERATED:{kind}-END\s*-->"
)


def main() -> None:
    parser = argparse.ArgumentParser(description="Update explicit VSA navigation generated blocks only.")
    parser.add_argument(
        "content_root",
        nargs="?",
        default=str(Path("generated") / "hugo" / "content"),
        help="Markdown content root to update. Defaults to generated\\hugo\\content.",
    )
    args = parser.parse_args()

    root = Path(args.content_root)
    if not root.exists():
        print(f"Niet gevonden: {root}")
        raise SystemExit(1)

    changed: list[Path] = []
    for path in sorted(root.rglob("*.md")):
        original = path.read_text(encoding="utf-8")
        updated = update_file_text(original, path, root)
        if updated != original:
            path.write_text(updated, encoding="utf-8")
            changed.append(path)

    if changed:
        print("Hugo navigatie-placeholders bijgewerkt.")
        for path in changed:
            print(f"- {path}")
    else:
        print("Geen navigatie-placeholders gewijzigd.")


def update_file_text(text: str, path: Path, root: Path) -> str:
    updated = text
    kinds = list(dict.fromkeys(MARKER_RE.findall(text)))

    for kind in kinds:
        updated = update_generated_block(updated, kind, render_items(kind, path, root))

    return remove_orphan_generated_blocks(updated)


def remove_orphan_generated_blocks(text: str) -> str:
    """Verwijder generated-blokken zonder bijbehorende marker (legacy PAGES naast PAGES-HERE)."""
    present = set(MARKER_RE.findall(text))
    updated = text
    for kind in ("HOME", "UP", "SIBLINGS", "CHILDREN", "PAGES", "PAGES-HERE"):
        if kind in present:
            continue
        pattern = re.compile(
            GENERATED_BLOCK_RE_TEMPLATE.format(kind=re.escape(kind)),
            flags=re.DOTALL,
        )
        updated = pattern.sub("", updated)
    return updated


def update_generated_block(text: str, kind: str, items: list[str]) -> str:
    marker_match = re.search(rf"<!--\s*VSA-NAV:{re.escape(kind)}\s*-->", text)
    if not marker_match:
        return text

    generated = render_generated_block(kind, items)
    pattern = re.compile(
        GENERATED_BLOCK_RE_TEMPLATE.format(kind=re.escape(kind)),
        flags=re.DOTALL,
    )

    match = pattern.search(text, marker_match.end())
    if match:
        return text[:match.start()] + generated + text[match.end():]

    return text[:marker_match.end()] + "\n" + generated + text[marker_match.end():]


def render_generated_block(kind: str, items: list[str]) -> str:
    return "\n".join([
        f"<!-- VSA-NAV-GENERATED:{kind}-START -->",
        *items,
        f"<!-- VSA-NAV-GENERATED:{kind}-END -->",
    ])


def render_items(kind: str, path: Path, root: Path) -> list[str]:
    if kind == "HOME":
        return [f"- [Home]({rel_link(path.parent, root)})"]

    if kind == "UP":
        return [f"- [Omhoog]({rel_link(path.parent, path.parent.parent)})"]

    if kind == "SIBLINGS":
        return sibling_items(path)

    if kind == "CHILDREN":
        return child_section_items(path.parent)

    if kind == "PAGES":
        return child_page_items(path.parent)

    if kind == "PAGES-HERE":
        return child_page_items_here(path.parent)

    return []


def sibling_items(path: Path) -> list[str]:
    current = path.parent
    parent = current.parent

    siblings = [
        item for item in sorted(parent.iterdir(), key=sort_key)
        if item.is_dir() and item != current and not item.name.startswith("_")
    ] if parent.exists() else []

    if not siblings:
        return ["<!-- Geen items voor SIBLINGS. -->"]

    return [f"- [{title_for_dir(item)}]({rel_link(current, item)})" for item in siblings]


def child_section_items(directory: Path) -> list[str]:
    children = [
        item for item in sorted(directory.iterdir(), key=sort_key)
        if item.is_dir() and (item / "_index.md").exists()
    ] if directory.exists() else []

    if not children:
        return ["<!-- Geen items voor CHILDREN. -->"]

    return [f"- [{title_for_dir(item)}]({item.name}/)" for item in children]


def child_page_items(directory: Path) -> list[str]:
    pages = [
        item for item in sorted(directory.glob("*.md"), key=sort_key)
        if is_nav_listed_page(item)
    ] if directory.exists() else []

    if not pages:
        return ["<!-- Geen items voor PAGES. -->"]

    return [f"- [{title_for_page(item)}]({page_nav_href(item)})" for item in pages]


def child_page_items_here(directory: Path) -> list[str]:
    """Toont alleen pagina’s in dezelfde directory, zonder recursie."""
    pages = [
        item for item in sorted(directory.glob("*.md"), key=sort_key)
        if is_nav_listed_page(item)
    ]

    if not pages:
        return ["<!-- Geen items voor PAGES-HERE. -->"]

    return [f"- [{title_for_page(item)}]({page_nav_href(item)})" for item in pages]


def is_nav_listed_page(path: Path) -> bool:
    if path.name == "_index.md":
        return False
    flags = frontmatter_flags(path)
    if flags.get("draft"):
        return False
    if flags.get("vsa_nav_exclude"):
        return False
    return True


def page_nav_href(path: Path) -> str:
    """Hugo permalink-stem (lowercase) — nodig voor case-sensitive publicatie (Linux)."""
    return f"{path.stem.lower()}/"


def frontmatter_flags(path: Path) -> dict[str, bool]:
    if not path.exists():
        return {}

    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}

    flags: dict[str, bool] = {}
    for line in text.splitlines()[1:]:
        if line.strip() == "---":
            break
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip().lower()
        if key not in ("draft", "vsa_nav_exclude"):
            continue
        normalized = value.strip().strip("\"'").lower()
        flags[key] = normalized in ("true", "yes", "1")

    return flags


def title_for_dir(path: Path) -> str:
    title = title_from_frontmatter(path / "_index.md")
    return title or path.name.replace("-", " ").title()


def title_for_page(path: Path) -> str:
    title = title_from_frontmatter(path)
    return title or path.stem.replace("-", " ").title()


def title_from_frontmatter(path: Path) -> str | None:
    if not path.exists():
        return None

    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return None

    for line in text.splitlines()[1:]:
        if line.strip() == "---":
            return None
        if line.strip().lower().startswith("title:"):
            value = line.split(":", 1)[1].strip()
            return value.strip("\"'") or None

    return None


def rel_link(from_dir: Path, to_path: Path) -> str:
    rel = Path(os.path.relpath(to_path, from_dir)).as_posix()
    if rel == ".":
        return "./"
    if not rel.endswith("/"):
        rel += "/"
    return rel


def sort_key(path: Path) -> tuple[str, str]:
    return (path.name.lower(), path.name)


if __name__ == "__main__":
    main()
