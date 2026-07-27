#!/usr/bin/env python3
"""Verify paired handbook/standard decision IDs."""

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
PAIRS = (
    (
        "ARCH",
        ROOT / "docs/architecture/AppleTeamHandbook.md",
        ROOT / "docs/architecture/AppleTeamArchitectureStandard.md",
        {f"ARCH-{number:03d}" for number in range(1, 18)},
    ),
    (
        "DLV",
        ROOT / "docs/delivery/AppleTeamDeliveryLoopHandbook.md",
        ROOT / "docs/delivery/AppleTeamDeliveryLoopStandard.md",
        {f"DLV-{number:03d}" for number in range(1, 19)},
    ),
)


def decision_ids(path: Path, prefix: str) -> set[str]:
    return set(re.findall(rf"\b{prefix}-\d{{3}}\b", path.read_text(encoding="utf-8")))


def main() -> int:
    failures: list[str] = []

    for prefix, handbook, standard, expected in PAIRS:
        handbook_ids = decision_ids(handbook, prefix)
        standard_ids = decision_ids(standard, prefix)

        if handbook_ids != standard_ids:
            failures.append(
                f"{prefix}: handbook/standard mismatch: "
                f"handbook-only={sorted(handbook_ids - standard_ids)}, "
                f"standard-only={sorted(standard_ids - handbook_ids)}"
            )

        if handbook_ids != expected:
            failures.append(
                f"{prefix}: unexpected canonical ID set: "
                f"missing={sorted(expected - handbook_ids)}, "
                f"extra={sorted(handbook_ids - expected)}"
            )

        print(f"{prefix}: {len(handbook_ids)} synchronized decision IDs")

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
