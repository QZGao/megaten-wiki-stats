#!/usr/bin/env python3
"""Upload local module files to wiki sandbox or live Module pages.

The page list is derived from the local src/ tree. By default, each local
``*.Module.lua`` file uploads to the matching ``Module:.../sandbox`` page, and
references to tracked Module pages are rewritten to their sandbox equivalents.
Pass ``--live`` to publish the exact local files to the live Module pages.
Dry-run is the default; pass ``--write`` to save pages.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
os.environ.setdefault("PYWIKIBOT_DIR", str(PROJECT_ROOT))

import pywikibot
from pywikibot import exceptions


MODULE_FILE_SUFFIX = ".Module.lua"
DEFAULT_SUMMARY = "Upload local module source"


@dataclass(frozen=True)
class ModuleTarget:
    live_title: str
    sandbox_title: str
    local_path: Path


@dataclass(frozen=True)
class PlannedUpload:
    target: ModuleTarget
    page_title: str
    target_text: str
    existing_text: str | None
    reference_replacements: int

    @property
    def exists(self) -> bool:
        return self.existing_text is not None

    @property
    def changed(self) -> bool:
        return self.existing_text != self.target_text


def page_title_from_module_file(src_root: Path, path: Path) -> str:
    """Map a local src/*.Module.lua file to its live Module page title."""
    relative = path.relative_to(src_root)
    parts = list(relative.parts)
    filename = parts[-1]
    if not filename.endswith(MODULE_FILE_SUFFIX):
        raise ValueError(f"Module source file must end with {MODULE_FILE_SUFFIX}: {path}")
    parts[-1] = filename[: -len(MODULE_FILE_SUFFIX)]
    return "Module:" + "/".join(parts)


def discover_targets(src_root: Path) -> list[ModuleTarget]:
    """Build live/sandbox/local upload targets from the local src/ tree."""
    if not src_root.is_dir():
        raise FileNotFoundError(f"src directory does not exist: {src_root}")

    targets = []
    for path in sorted(src_root.rglob(f"*{MODULE_FILE_SUFFIX}")):
        live_title = page_title_from_module_file(src_root, path)
        targets.append(
            ModuleTarget(
                live_title=live_title,
                sandbox_title=f"{live_title}/sandbox",
                local_path=path,
            )
        )
    return targets


def read_local_text(path: Path) -> str:
    """Read a local module file as UTF-8 source text."""
    return path.read_text(encoding="utf-8")


def fetch_optional_page_text(page: pywikibot.Page) -> str | None:
    """Fetch existing page text, returning None when the page is absent."""
    try:
        return page.get()
    except exceptions.NoPageError:
        return None


def build_sandbox_text(local_text: str, targets: list[ModuleTarget]) -> tuple[str, int]:
    """Rewrite tracked Module page references to their sandbox equivalents."""
    replacements = {target.live_title: target.sandbox_title for target in targets}
    titles = sorted(replacements, key=len, reverse=True)
    pattern = re.compile(
        r"(?:" + "|".join(re.escape(title) for title in titles) + r")(?=$|[^A-Za-z0-9_/-])"
    )

    def replace(match: re.Match[str]) -> str:
        return replacements[match.group(0)]

    return pattern.subn(replace, local_text)


def build_upload_text(
    target: ModuleTarget,
    targets: list[ModuleTarget],
    live: bool,
) -> tuple[str, int]:
    """Build the source text to upload for live or sandbox mode."""
    local_text = read_local_text(target.local_path)
    if live:
        return local_text, 0
    return build_sandbox_text(local_text, targets)


def describe_delta(old_text: str | None, new_text: str) -> str:
    """Return compact size and line deltas for dry-run reporting."""
    if old_text is None:
        return f"create {len(new_text)} bytes, {line_count(new_text)} lines"

    byte_delta = len(new_text.encode("utf-8")) - len(old_text.encode("utf-8"))
    line_delta = line_count(new_text) - line_count(old_text)
    return f"{signed(byte_delta)} bytes, {signed(line_delta)} lines"


def line_count(text: str) -> int:
    """Count display lines without treating a trailing newline as an extra line."""
    if not text:
        return 0
    return len(text.splitlines())


def signed(value: int) -> str:
    """Format an integer delta with an explicit sign."""
    return f"{value:+d}"


def build_plan(site: pywikibot.Site, targets: list[ModuleTarget], live: bool) -> list[PlannedUpload]:
    """Compare local upload text against each target wiki page."""
    plan = []
    for target in targets:
        page_title = target.live_title if live else target.sandbox_title
        target_text, reference_replacements = build_upload_text(target, targets, live)
        existing_text = fetch_optional_page_text(pywikibot.Page(site, page_title))
        plan.append(
            PlannedUpload(
                target=target,
                page_title=page_title,
                target_text=target_text,
                existing_text=existing_text,
                reference_replacements=reference_replacements,
            )
        )
    return plan


def print_plan(plan: list[PlannedUpload], live: bool, dry_run: bool) -> None:
    """Print the exact wiki page replacements that will be made."""
    changes = [item for item in plan if item.changed]
    mode = "DRY RUN" if dry_run else "WRITE"
    destination = "live Module pages" if live else "sandbox Module pages"
    print(f"{mode}: discovered {len(plan)} module page(s) from src/.")
    print(f"Destination: {destination}")
    print()
    print(f"On-wiki changes: {len(changes)}")

    if not changes:
        print("  none")
        return

    for item in changes:
        action = "UPDATE" if item.exists else "CREATE"
        message = (
            f"  {action} {item.page_title} "
            f"<- {item.target.local_path.relative_to(PROJECT_ROOT)} "
            f"({describe_delta(item.existing_text, item.target_text)}"
        )
        if not live:
            message += f", {item.reference_replacements} reference rewrite(s)"
        message += ")"
        print(message)


def write_plan(site: pywikibot.Site, plan: list[PlannedUpload], summary: str) -> None:
    """Save changed wiki pages with the planned upload text."""
    for item in plan:
        if not item.changed:
            continue
        page = pywikibot.Page(site, item.page_title)
        page.text = item.target_text
        page.save(summary=summary, minor=False)


def parse_args() -> argparse.Namespace:
    """Parse command-line options for dry-run, sandbox upload, or live publish."""
    parser = argparse.ArgumentParser(
        description="Upload local src module files to sandbox pages, or to live pages with --live."
    )
    parser.add_argument(
        "--src-dir",
        type=Path,
        default=PROJECT_ROOT / "src",
        help="Local source directory used to discover module pages.",
    )
    parser.add_argument(
        "--live",
        action="store_true",
        help="Publish to live Module pages instead of Module:.../sandbox pages.",
    )
    parser.add_argument(
        "--write",
        action="store_true",
        help="Apply changes. Without this flag, the script only reports planned changes.",
    )
    parser.add_argument(
        "--summary",
        default=DEFAULT_SUMMARY,
        help="Edit summary used when --write saves pages.",
    )
    return parser.parse_args()


def main() -> int:
    """Run the upload planner, and optionally save changed wiki pages."""
    args = parse_args()
    src_root = args.src_dir.resolve()

    try:
        targets = discover_targets(src_root)
        site = pywikibot.Site()
        if args.write:
            site.login()
        plan = build_plan(site, targets, args.live)
        print_plan(plan, live=args.live, dry_run=not args.write)
        if args.write:
            write_plan(site, plan, args.summary)
            print()
            print("Upload completed.")
        else:
            print()
            print("No changes written. Re-run with --write to apply this upload.")
            if not args.live:
                print("Use --live with --write to publish these local files to live Module pages.")
    except (OSError, RuntimeError, exceptions.Error) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
