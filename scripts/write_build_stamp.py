"""Schrijf data/build.yaml met bouwtijd (Europe/Amsterdam) voor Hugo."""

from __future__ import annotations

import argparse
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = REPO_ROOT / "data" / "build.yaml"
AMSTERDAM_TZ = "Europe/Amsterdam"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Schrijf Hugo data/build.yaml met bouwtijd Amsterdam.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="Doelbestand (default: data/build.yaml).",
    )
    parser.add_argument(
        "--time",
        help="Vaste tijdstring (default: nu in Europe/Amsterdam).",
    )
    return parser.parse_args()


def _amsterdam_now_windows() -> str:
    script = (
        "$tz = [TimeZoneInfo]::FindSystemTimeZoneById('W. Europe Standard Time'); "
        "$t = [TimeZoneInfo]::ConvertTimeFromUtc([DateTime]::UtcNow, $tz); "
        "$abbr = if ($tz.IsDaylightSavingTime($t)) { 'CEST' } else { 'CET' }; "
        "$t.ToString('yyyy-MM-dd HH:mm') + ' ' + $abbr"
    )
    result = subprocess.run(
        ["powershell", "-NoProfile", "-Command", script],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def format_build_time(when: datetime | None = None) -> str:
    if when is not None:
        if when.tzinfo is None:
            when = when.replace(tzinfo=ZoneInfo(AMSTERDAM_TZ))
        else:
            when = when.astimezone(ZoneInfo(AMSTERDAM_TZ))
        return when.strftime("%Y-%m-%d %H:%M %Z")

    try:
        dt = datetime.now(ZoneInfo(AMSTERDAM_TZ))
    except ZoneInfoNotFoundError:
        if sys.platform == "win32":
            return _amsterdam_now_windows()
        raise
    return dt.strftime("%Y-%m-%d %H:%M %Z")


def main() -> int:
    args = parse_args()
    build_time = args.time or format_build_time()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(f'time: "{build_time}"\n', encoding="utf-8")
    print(f"Bouwtijd geschreven: {build_time} -> {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
