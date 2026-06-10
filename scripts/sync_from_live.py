#!/usr/bin/env python3
"""Synchronize local and sandbox module copies from live wiki pages.

The page list is derived from the local src/ tree. For each
``*.Module.lua`` file, the script maps the path back to its live Module page,
then compares that live source against both the matching ``/sandbox`` page and
the local file. Dry-run is the default; pass ``--write`` to replace the sandbox
page and local file content with the live source.
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


@dataclass(frozen=True)
class ModuleTarget:
    live_title: str
    sandbox_title: str
    local_path: Path


@dataclass(frozen=True)
class PlannedSync:
    target: ModuleTarget
    live_text: str
    sandbox_target_text: str
    sandbox_reference_replacements: int
    sandbox_exists: bool
    sandbox_text: str | None
    local_text: str

    @property
    def sandbox_changed(self) -> bool:
        return self.sandbox_text != self.sandbox_target_text

    @property
    def local_changed(self) -> bool:
        return self.local_text != self.live_text


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
    """Build live/sandbox/local sync targets from the local src/ tree."""
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


def fetch_page_text(page: pywikibot.Page) -> str:
    """Fetch source text for a page, failing clearly if it does not exist."""
    try:
        return page.get()
    except exceptions.NoPageError as exc:
        raise RuntimeError(f"Live page does not exist: {page.title()}") from exc


def fetch_optional_page_text(page: pywikibot.Page) -> tuple[bool, str | None]:
    """Fetch source text for an optional page, returning exists/text."""
    try:
        return True, page.get()
    except exceptions.NoPageError:
        return False, None


def read_local_text(path: Path) -> str:
    """Read a local module file as UTF-8 source text."""
    return path.read_text(encoding="utf-8")


def build_sandbox_text(live_text: str, targets: list[ModuleTarget]) -> tuple[str, int]:
    """Rewrite tracked Module page references to their sandbox equivalents."""
    replacements = {target.live_title: target.sandbox_title for target in targets}
    titles = sorted(replacements, key=len, reverse=True)
    pattern = re.compile(
        r"(?:" + "|".join(re.escape(title) for title in titles) + r")(?=$|[^A-Za-z0-9_/-])"
    )

    def replace(match: re.Match[str]) -> str:
        return replacements[match.group(0)]

    return pattern.subn(replace, live_text)


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


def build_plan(site: pywikibot.Site, targets: list[ModuleTarget]) -> list[PlannedSync]:
    """Fetch live, sandbox, and local source for every sync target."""
    plan = []
    for target in targets:
        live_page = pywikibot.Page(site, target.live_title)
        sandbox_page = pywikibot.Page(site, target.sandbox_title)
        live_text = fetch_page_text(live_page)
        sandbox_target_text, sandbox_reference_replacements = build_sandbox_text(live_text, targets)
        sandbox_exists, sandbox_text = fetch_optional_page_text(sandbox_page)
        local_text = read_local_text(target.local_path)
        plan.append(
            PlannedSync(
                target=target,
                live_text=live_text,
                sandbox_target_text=sandbox_target_text,
                sandbox_reference_replacements=sandbox_reference_replacements,
                sandbox_exists=sandbox_exists,
                sandbox_text=sandbox_text,
                local_text=local_text,
            )
        )
    return plan


def print_plan(plan: list[PlannedSync], dry_run: bool) -> None:
    """Print the exact local and sandbox changes that will be made."""
    sandbox_changes = [item for item in plan if item.sandbox_changed]
    local_changes = [item for item in plan if item.local_changed]

    mode = "DRY RUN" if dry_run else "WRITE"
    print(f"{mode}: discovered {len(plan)} module page(s) from src/.")

    print()
    print(f"On-wiki sandbox changes: {len(sandbox_changes)}")
    if sandbox_changes:
        for item in sandbox_changes:
            action = "CREATE" if not item.sandbox_exists else "UPDATE"
            print(
                f"  {action} {item.target.sandbox_title} "
                f"<- {item.target.live_title} with sandbox references "
                f"({describe_delta(item.sandbox_text, item.sandbox_target_text)}, "
                f"{item.sandbox_reference_replacements} reference rewrite(s))"
            )
    else:
        print("  none")

    print()
    print(f"Local src changes: {len(local_changes)}")
    if local_changes:
        for item in local_changes:
            print(
                f"  UPDATE {item.target.local_path.relative_to(PROJECT_ROOT)} "
                f"<- {item.target.live_title} "
                f"({describe_delta(item.local_text, item.live_text)})"
            )
    else:
        print("  none")


def write_plan(site: pywikibot.Site, plan: list[PlannedSync], summary: str) -> None:
    """Replace changed sandbox pages and local files with live source text."""
    for item in plan:
        if item.local_changed:
            item.target.local_path.write_text(item.live_text, encoding="utf-8", newline="\n")

        if item.sandbox_changed:
            sandbox_page = pywikibot.Page(site, item.target.sandbox_title)
            sandbox_page.text = item.sandbox_target_text
            sandbox_page.save(summary=summary, minor=False)


def parse_args() -> argparse.Namespace:
    """Parse command-line options for dry-run or write sync modes."""
    parser = argparse.ArgumentParser(
        description="Sync Module sandbox pages and local src files from live Module pages."
    )
    parser.add_argument(
        "--src-dir",
        type=Path,
        default=PROJECT_ROOT / "src",
        help="Local source directory used to discover module pages.",
    )
    parser.add_argument(
        "--write",
        action="store_true",
        help="Apply changes. Without this flag, the script only reports planned changes.",
    )
    parser.add_argument(
        "--summary",
        default="Sync sandbox module source from live module",
        help="Edit summary used when --write updates sandbox pages.",
    )
    return parser.parse_args()


def main() -> int:
    """Run the sync planner, and optionally apply the planned replacements."""
    args = parse_args()
    src_root = args.src_dir.resolve()

    try:
        targets = discover_targets(src_root)
        site = pywikibot.Site()
        if args.write:
            site.login()
        plan = build_plan(site, targets)
        print_plan(plan, dry_run=not args.write)
        if args.write:
            write_plan(site, plan, args.summary)
            print()
            print("Write sync completed.")
        else:
            print()
            print("No changes written. Re-run with --write to apply this sync.")
    except (OSError, RuntimeError, exceptions.Error) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
