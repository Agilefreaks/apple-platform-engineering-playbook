#!/usr/bin/env python3
"""Check local Markdown links and fenced-block balance without network access."""

from pathlib import Path
import re
import sys
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[1]
LINK_PATTERN = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
REMOTE_PREFIXES = ("http://", "https://", "mailto:")


def local_target(raw_target: str) -> str | None:
    target = raw_target.strip()
    if not target or target.startswith("#") or target.startswith(REMOTE_PREFIXES):
        return None
    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1]
    target = target.split("#", maxsplit=1)[0]
    return unquote(target)


def main() -> int:
    failures: list[str] = []
    markdown_files = sorted(ROOT.rglob("*.md"))

    for path in markdown_files:
        text = path.read_text(encoding="utf-8")

        for fence in ("~~~", "```"):
            if text.count(fence) % 2:
                failures.append(f"{path.relative_to(ROOT)}: unbalanced {fence} fence")

        for raw_target in LINK_PATTERN.findall(text):
            target = local_target(raw_target)
            if target is None:
                continue
            resolved = (path.parent / target).resolve()
            if not resolved.exists():
                failures.append(
                    f"{path.relative_to(ROOT)}: missing local link target {raw_target}"
                )

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1

    print(f"Markdown: {len(markdown_files)} files, local links and fences valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
