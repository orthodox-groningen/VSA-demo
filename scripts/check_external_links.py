"""Controleer externe http(s)-links in de gebouwde Hugo-site.

Standaard niet-blocking bedoeld voor CI (continue-on-error).
Lokaal: scripts\\check.cmd --external
"""

from __future__ import annotations

import argparse
import sys
import urllib.error
import urllib.request
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SITE_DIR = REPO_ROOT / "generated" / "site"
USER_AGENT = (
    "VSA-demo-external-link-check/1.0 "
    "(+https://github.com/orthodox-groningen/VSA-demo)"
)


class HrefCollector(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.hrefs: list[str] = []

    def handle_starttag(self, tag: str, attrs):
        data = dict(attrs)
        href = data.get("href")
        if href:
            self.hrefs.append(href)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Controleer externe https/http links in Hugo-output.",
    )
    parser.add_argument(
        "--site-dir",
        type=Path,
        default=DEFAULT_SITE_DIR,
        help="Gebouwde site-root (default: generated/site).",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=10.0,
        help="Timeout per request in seconden (default: 10).",
    )
    parser.add_argument(
        "--max-urls",
        type=int,
        default=100,
        help="Maximaal aantal unieke URLs om te checken (default: 100).",
    )
    return parser.parse_args()


def collect_external_urls(site_dir: Path) -> list[str]:
    found: set[str] = set()
    for html in site_dir.rglob("*.html"):
        parser = HrefCollector()
        parser.feed(html.read_text(encoding="utf-8", errors="ignore"))
        for href in parser.hrefs:
            href = href.strip().split("#", 1)[0].split("?", 1)[0]
            if href.startswith("http://") or href.startswith("https://"):
                found.add(href)
    return sorted(found)


def _open(url: str, method: str, timeout: float):
    request = urllib.request.Request(
        url,
        method=method,
        headers={"User-Agent": USER_AGENT},
    )
    return urllib.request.urlopen(request, timeout=timeout)


def check_url(url: str, timeout: float) -> str | None:
    """Return fouttekst of None bij succes."""
    if urlparse(url).scheme not in ("http", "https"):
        return "geen http(s)-URL"

    for method in ("HEAD", "GET"):
        try:
            with _open(url, method, timeout) as response:
                if 200 <= response.status < 400:
                    return None
                if method == "HEAD" and response.status in (405, 501):
                    continue
                return f"HTTP {response.status}"
        except urllib.error.HTTPError as exc:
            if method == "HEAD" and exc.code in (405, 501):
                continue
            if 200 <= exc.code < 400:
                return None
            if method == "HEAD":
                continue
            return f"HTTP {exc.code}"
        except Exception as exc:  # noqa: BLE001 - rapportage
            if method == "HEAD":
                continue
            return f"{type(exc).__name__}: {exc}"

    return "geen bruikbaar antwoord"


def main() -> int:
    args = parse_args()
    site_dir = args.site_dir.resolve()

    if not site_dir.is_dir():
        print(f"Niet gevonden: {site_dir}", file=sys.stderr)
        print("Draai eerst scripts\\build-hugo.cmd", file=sys.stderr)
        return 2

    urls = collect_external_urls(site_dir)
    if len(urls) > args.max_urls:
        print(
            f"Let op: {len(urls)} externe URLs gevonden; "
            f"controleer de eerste {args.max_urls}."
        )
        urls = urls[: args.max_urls]

    if not urls:
        print("Externe linkcheck: geen http(s)-links gevonden.")
        return 0

    failures: list[tuple[str, str]] = []
    for url in urls:
        err = check_url(url, args.timeout)
        if err:
            failures.append((url, err))
            print(f"FAIL {url} ({err})")
        else:
            print(f"OK   {url}")

    if failures:
        print()
        print(f"Externe linkcheck: {len(failures)}/{len(urls)} mislukt.")
        return 1

    print(f"Externe linkcheck: OK ({len(urls)} URL(s)).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
