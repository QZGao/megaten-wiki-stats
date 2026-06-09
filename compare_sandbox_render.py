#!/usr/bin/env python3
"""Compare rendered MediaWiki HTML for the live and sandbox stats templates.

The script uses action=parse so it compares the article content HTML produced by
MediaWiki, not Fandom's full page wrapper with ads, navigation, and scripts.
"""

from __future__ import annotations

import argparse
import difflib
import json
import re
import sys
from pathlib import Path
from typing import Tuple
from urllib.error import HTTPError, URLError
from urllib.parse import unquote, urlencode, urlsplit
from urllib.request import Request, urlopen


DEFAULT_API = "https://megamitensei.fandom.com/api.php"
DEFAULT_LEFT = "https://megamitensei.fandom.com/wiki/User:Greykid/sandbox2"
DEFAULT_RIGHT = "https://megamitensei.fandom.com/wiki/User:Greykid/sandbox3"
USER_AGENT = "StatsModuleRenderCompare/1.0 (https://github.com/QZGao/megaten-wiki-stats/blob/main/compare_sandbox_render.py)"


def title_from_page_arg(value: str) -> str:
    """Accept either a wiki page URL or a page title."""
    if value.startswith(("http://", "https://")):
        path = urlsplit(value).path
        marker = "/wiki/"
        if marker not in path:
            raise ValueError(f"URL does not contain {marker!r}: {value}")
        value = path.split(marker, 1)[1]
    return unquote(value).replace("_", " ")


def fetch_rendered_html(api_url: str, page: str, timeout: float) -> str:
    params = {
        "action": "parse",
        "format": "json",
        "formatversion": "2",
        "page": page,
        "prop": "text",
        "disableeditsection": "1",
        "disablelimitreport": "1",
        "disabletoc": "1",
    }
    url = f"{api_url}?{urlencode(params)}"
    request = Request(url, headers={"User-Agent": USER_AGENT})

    with urlopen(request, timeout=timeout) as response:
        payload = json.load(response)

    if "error" in payload:
        error = payload["error"]
        code = error.get("code", "unknown")
        info = error.get("info", "unknown API error")
        raise RuntimeError(f"API error for {page!r}: {code}: {info}")

    try:
        return payload["parse"]["text"]
    except KeyError as exc:
        raise RuntimeError(f"API response for {page!r} did not include parse.text") from exc


def safe_filename(page: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_.-]+", "_", page).strip("_")
    return cleaned or "page"


def normalize_rendered_html(html: str) -> str:
    """Remove Fandom wrapper noise and canonicalize whitespace.

    This mode is intentionally conservative about content: it strips TemplateStyles
    tags, unwraps portable-infobox aside/nav shells, removes parser-empty
    paragraphs, and then normalizes whitespace. Use exact mode when byte-for-byte
    parser HTML matters.
    """
    html = re.sub(
        r'<style\b[^>]*\bdata-mw-deduplicate="[^"]*"[^>]*>.*?</style>',
        "",
        html,
        flags=re.DOTALL,
    )
    html = re.sub(
        r'<link\b[^>]*\brel="mw-deduplicated-inline-style"[^>]*/>',
        "",
        html,
    )
    html = re.sub(
        r'<aside\b[^>]*>\s*<nav\b[^>]*>(.*?)</nav>\s*</aside>',
        r"\1",
        html,
        flags=re.DOTALL,
    )
    html = re.sub(r'<p\b[^>]*\bclass="mw-empty-elt"[^>]*></p>', "", html)
    html = re.sub(r"<p>\s*</p>", "", html)
    html = re.sub(r">\s+<", "><", html)
    html = re.sub(r">\s+", ">", html)
    html = re.sub(r"\s+<", "<", html)
    html = re.sub(r"\s+", " ", html)
    html = re.sub(r">\s*<", ">\n<", html)
    return html.strip()


def ignore_expected_differences(html: str) -> str:
    """Canonicalize known page-specific differences between the two sandboxes."""
    return re.sub(
        r"https://dx2wiki\.com/index\.php/Greykid/sandbox[23]",
        "https://dx2wiki.com/index.php/Greykid/sandbox",
        html,
    )


def write_outputs(
    out_dir: Path,
    left: Tuple[str, str],
    right: Tuple[str, str],
    diff_text: str,
) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    left_title, left_html = left
    right_title, right_html = right

    left_path = out_dir / f"{safe_filename(left_title)}.html"
    right_path = out_dir / f"{safe_filename(right_title)}.html"
    diff_path = out_dir / "render.diff"

    left_path.write_text(left_html, encoding="utf-8", newline="\n")
    right_path.write_text(right_html, encoding="utf-8", newline="\n")
    diff_path.write_text(diff_text, encoding="utf-8", newline="\n")

    print(f"Wrote {left_path}")
    print(f"Wrote {right_path}")
    print(f"Wrote {diff_path}")


def build_diff(left_title: str, left_html: str, right_title: str, right_html: str, context: int) -> str:
    left_lines = left_html.splitlines(keepends=True)
    right_lines = right_html.splitlines(keepends=True)
    return "".join(
        difflib.unified_diff(
            left_lines,
            right_lines,
            fromfile=left_title,
            tofile=right_title,
            n=context,
        )
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Compare action=parse rendered HTML for two Megami Tensei Wiki pages."
    )
    parser.add_argument("left", nargs="?", default=DEFAULT_LEFT, help="First page URL or title.")
    parser.add_argument("right", nargs="?", default=DEFAULT_RIGHT, help="Second page URL or title.")
    parser.add_argument("--api", default=DEFAULT_API, help="MediaWiki API endpoint.")
    parser.add_argument(
        "--mode",
        choices=("exact", "normalized"),
        default="exact",
        help="exact compares parser HTML; normalized strips wrapper noise and normalizes whitespace.",
    )
    parser.add_argument("--context", type=int, default=3, help="Number of context lines in the diff.")
    parser.add_argument(
        "--max-diff-lines",
        type=int,
        default=250,
        help="Maximum diff lines to print to stdout. Use 0 for no limit.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Do not ignore known page-specific sandbox differences.",
    )
    parser.add_argument("--out-dir", type=Path, help="Write both HTML renders and render.diff here on mismatch.")
    parser.add_argument("--timeout", type=float, default=30.0, help="HTTP timeout in seconds.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    try:
        left_title = title_from_page_arg(args.left)
        right_title = title_from_page_arg(args.right)
        left_html = fetch_rendered_html(args.api, left_title, args.timeout)
        right_html = fetch_rendered_html(args.api, right_title, args.timeout)
    except (HTTPError, URLError, TimeoutError, ValueError, RuntimeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2

    compared_left = left_html
    compared_right = right_html
    if args.mode == "normalized":
        compared_left = normalize_rendered_html(left_html)
        compared_right = normalize_rendered_html(right_html)
    if not args.strict:
        compared_left = ignore_expected_differences(compared_left)
        compared_right = ignore_expected_differences(compared_right)

    if compared_left == compared_right:
        print(f"MATCH: rendered article HTML is identical in {args.mode} mode.")
        print(f"Left:  {left_title}")
        print(f"Right: {right_title}")
        return 0

    diff_text = build_diff(left_title, compared_left, right_title, compared_right, args.context)
    print(f"MISMATCH: rendered article HTML differs in {args.mode} mode.")
    diff_lines = diff_text.splitlines(keepends=True)
    if args.max_diff_lines and len(diff_lines) > args.max_diff_lines:
        print("".join(diff_lines[: args.max_diff_lines]), end="")
        omitted = len(diff_lines) - args.max_diff_lines
        print(f"\n... omitted {omitted} diff lines. Use --max-diff-lines 0 or --out-dir for the full diff.")
    else:
        print(diff_text, end="" if diff_text.endswith("\n") else "\n")

    if args.out_dir:
        write_outputs(
            args.out_dir,
            (left_title, compared_left),
            (right_title, compared_right),
            diff_text,
        )

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
