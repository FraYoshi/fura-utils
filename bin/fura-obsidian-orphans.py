#!/usr/bin/env python3
"""
fura-obsidian-orphans — Find orphaned files in an Obsidian vault.

Scans for files not referenced in markdown files, with configurable
exclude/include lists via ~/.config/furayoshi/config.sh or env vars.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Set, Optional, List


# ──────────────────────────────────────────────────────────────────────
CONFIG_DIR = Path.home() / ".config" / "furayoshi"
CONFIG_FILE = CONFIG_DIR / "config.sh"

# User-specified defaults (env > config.sh > these)
DEFAULT_EXCLUDE_EXTS = {".md", ".base"}
DEFAULT_EXCLUDE_DIRS = {".trash", ".obsidian", ".git"}
DEFAULT_EXCLUDE_FILES = {".gitignore", ".gitattributes", ".gitmodules"}

ENV_EXCLUDE_EXTS   = "OBSIDIAN_ORPH_EXCLUDE_EXT"
ENV_EXCLUDE_DIRS   = "OBSIDIAN_ORPH_EXCLUDE_DIRS"
ENV_EXCLUDE_FILES  = "OBSIDIAN_ORPH_EXCLUDE_FILES"
ENV_ONLY_EXTS      = "OBSIDIAN_ORPH_ONLY_EXT"
ENV_ONLY_DIRS      = "OBSIDIAN_ORPH_ONLY_DIRS"
ENV_DEFAULT_VAULT  = "OBSIDIAN_ORPH_VAULT"

MARKDOWN_EXTS = {".md", ".base", ".mdx", ".markdown"}
# ──────────────────────────────────────────────────────────────────────


def _norm_exts(val: str) -> set[str]:
    return {
        e.strip().lower() if e.strip().startswith(".") else f".{e.strip().lower()}"
        for e in val.split(",") if e.strip()
    }


def _norm_dirs(val: str) -> set[str]:
    return {e.strip().lower() for e in val.split(",") if e.strip() and "/" not in e.strip() and "\\" not in e.strip()}


def _norm_files(val: str) -> set[str]:
    return {e.strip().lower() for e in val.split(",") if e.strip()}


def _source_config(var: str) -> str | None:
    """Source config.sh and echo $VAR. Returns value or None."""
    if not CONFIG_FILE.is_file():
        return None
    try:
        res = subprocess.run(
            ["bash", "-c", f"source '{CONFIG_FILE}' && echo \"${var}\""],
            capture_output=True, text=True, timeout=2
        )
        if res.returncode == 0 and res.stdout.strip():
            return res.stdout.strip()
    except Exception:
        pass
    return None


def load_config() -> tuple[
    set[str], set[str], set[str],
    Optional[set[str]], Optional[set[str]],
    Optional[Path]
]:
    """
    Load config with precedence: env var > config.sh > defaults.
    Returns: (exclude_exts, exclude_dirs, exclude_files, only_exts, only_dirs, default_vault)
    """
    exts = _norm_exts(os.environ.get(ENV_EXCLUDE_EXTS, "")) or _norm_exts(_source_config(ENV_EXCLUDE_EXTS) or "") or DEFAULT_EXCLUDE_EXTS
    dirs = _norm_dirs(os.environ.get(ENV_EXCLUDE_DIRS, "")) or _norm_dirs(_source_config(ENV_EXCLUDE_DIRS) or "") or DEFAULT_EXCLUDE_DIRS
    files = _norm_files(os.environ.get(ENV_EXCLUDE_FILES, "")) or _norm_files(_source_config(ENV_EXCLUDE_FILES) or "") or DEFAULT_EXCLUDE_FILES

    only_exts = None
    val = os.environ.get(ENV_ONLY_EXTS) or _source_config(ENV_ONLY_EXTS)
    if val:
        only_exts = _norm_exts(val)

    only_dirs = None
    val = os.environ.get(ENV_ONLY_DIRS) or _source_config(ENV_ONLY_DIRS)
    if val:
        only_dirs = _norm_dirs(val)

    vault = None
    val = os.environ.get(ENV_DEFAULT_VAULT) or _source_config(ENV_DEFAULT_VAULT)
    if val:
        vault = Path(val).expanduser().resolve()

    return exts, dirs, files, only_exts, only_dirs, vault


EXCLUDE_EXTS, EXCLUDE_DIRS, EXCLUDE_FILES, ONLY_EXTS, ONLY_DIRS, DEFAULT_VAULT = load_config()


def _is_excluded_dir(rel_path: Path, exclude_dirs: Set[str]) -> bool:
    return any(part.lower() in exclude_dirs for part in rel_path.parts)


def _matches_only_dirs(rel_path: Path, only_dirs: Optional[Set[str]]) -> bool:
    """True if file is inside one of the ONLY_DIRS (or no restriction)."""
    if only_dirs is None:
        return True
    return any(part.lower() in only_dirs for part in rel_path.parts[:-1])


def collect_referenced_files(vault: Path) -> set[str]:
    """Collect all filenames and stems referenced in markdown files."""
    referenced: set[str] = set()

    for md_file in vault.rglob("*"):
        if not md_file.is_file() or md_file.suffix.lower() not in MARKDOWN_EXTS:
            continue
        rel = md_file.relative_to(vault)
        if _is_excluded_dir(rel, EXCLUDE_DIRS):
            continue

        try:
            text = md_file.read_text(encoding="utf-8")
        except Exception:
            continue

        # Wikilinks: [[name]] or [[name|alias]] or ![[name]]
        for m in re.finditer(r"!?\[\[([^|\]]+)(?:\|[^\]]+)?\]\]", text):
            target = m.group(1).strip()
            referenced.add(target)
            referenced.add(Path(target).stem)

        # Markdown links/images: [text](path) or ![alt](path)
        for m in re.finditer(r"!?\[[^\]]*\]\(([^)\s]+)(?:\s+[\"'][^\"']*[\"'])?\)", text):
            target = m.group(1).strip().split("#")[0].split("?")[0]
            if target and not target.startswith(("http://", "https://", "mailto:", "data:")):
                from urllib.parse import unquote
                target = unquote(target)
                referenced.add(target)
                referenced.add(Path(target).stem)

    return referenced


def find_candidate_files(vault: Path, scan_dirs: list[Path]) -> list[Path]:
    """Find files to check: not excluded, and matching ONLY_* filters if set."""
    candidates: list[Path] = []
    exts = {e.lower() for e in EXCLUDE_EXTS}

    for d in scan_dirs:
        for f in d.rglob("*"):
            if not f.is_file():
                continue
            rel = f.relative_to(vault)

            if _is_excluded_dir(rel, EXCLUDE_DIRS):
                continue
            if f.name.lower() in EXCLUDE_FILES:
                continue
            if not _matches_only_dirs(rel, ONLY_DIRS):
                continue

            if ONLY_EXTS is not None:
                if f.suffix.lower() not in ONLY_EXTS:
                    continue
            else:
                if f.suffix.lower() in exts:
                    continue

            candidates.append(f)

    return candidates


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Find orphaned files in an Obsidian vault.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
Configuration (precedence: env > ~/.config/furayoshi/config.sh > defaults):
  Config file: {CONFIG_FILE}

  Env vars:
    {ENV_EXCLUDE_EXTS}   = .md,.base,.txt,.pdf (extensions to EXCLUDE)
    {ENV_EXCLUDE_DIRS}   = .trash,.obsidian,.git (directory names to SKIP)
    {ENV_EXCLUDE_FILES}  = .gitignore,.env (exact filenames to SKIP)
    {ENV_ONLY_EXTS}      = .png,.jpg,.pdf      (ONLY scan these extensions)
    {ENV_ONLY_DIRS}      = media,attachments   (ONLY scan under these dirs)
    {ENV_DEFAULT_VAULT}  = ~/vaults/main       (default vault path)

Defaults:
  Excluded extensions: {", ".join(sorted(DEFAULT_EXCLUDE_EXTS))}
  Excluded directories: {", ".join(sorted(DEFAULT_EXCLUDE_DIRS))}
  Excluded files: {", ".join(sorted(DEFAULT_EXCLUDE_FILES))}
  Only extensions: {", ".join(sorted(ONLY_EXTS)) if ONLY_EXTS else "(none - blacklist mode)"}
  Only directories: {", ".join(sorted(ONLY_DIRS)) if ONLY_DIRS else "(none - scan all)"}
  Default vault: {DEFAULT_VAULT or "(none)"}

Usage examples:
  fura-obsidian-orphans.py                    # uses {ENV_DEFAULT_VAULT}
  fura-obsidian-orphans.py media              # scans {ENV_DEFAULT_VAULT}/media
  fura-obsidian-orphans.py /path/to/vault     # scans entire vault
  fura-obsidian-orphans.py /path/to/vault assets images  # scans subdirs
  fura-obsidian-orphans.py --config           # show resolved config
        """
    )
    parser.add_argument(
        "vault_or_dir", nargs="?",
        help="Vault path (or subdirectory if default vault is configured)"
    )
    parser.add_argument(
        "extra_dirs", nargs="*", default=[],
        help="Additional subdirectories to scan (relative to vault)"
    )
    parser.add_argument(
        "--config", action="store_true",
        help="Print resolved configuration and exit"
    )
    args = parser.parse_args()

    if args.config:
        print(f"Config file:       {CONFIG_FILE}")
        print(f"Env EXTS:          {ENV_EXCLUDE_EXTS}={os.environ.get(ENV_EXCLUDE_EXTS, '(unset)')}")
        print(f"Env DIRS:          {ENV_EXCLUDE_DIRS}={os.environ.get(ENV_EXCLUDE_DIRS, '(unset)')}")
        print(f"Env FILES:         {ENV_EXCLUDE_FILES}={os.environ.get(ENV_EXCLUDE_FILES, '(unset)')}")
        print(f"Env ONLY_EXTS:     {ENV_ONLY_EXTS}={os.environ.get(ENV_ONLY_EXTS, '(unset)')}")
        print(f"Env ONLY_DIRS:     {ENV_ONLY_DIRS}={os.environ.get(ENV_ONLY_DIRS, '(unset)')}")
        print(f"Env VAULT:         {ENV_DEFAULT_VAULT}={os.environ.get(ENV_DEFAULT_VAULT, '(unset)')}")
        print(f"Resolved exts:     {', '.join(sorted(EXCLUDE_EXTS))}")
        print(f"Resolved dirs:     {', '.join(sorted(EXCLUDE_DIRS))}")
        print(f"Resolved files:    {', '.join(sorted(EXCLUDE_FILES))}")
        print(f"Only extensions:   {', '.join(sorted(ONLY_EXTS)) if ONLY_EXTS else '(none - blacklist mode)'}")
        print(f"Only directories:  {', '.join(sorted(ONLY_DIRS)) if ONLY_DIRS else '(none - scan all)'}")
        print(f"Default vault:     {DEFAULT_VAULT or '(none)'}")
        return 0

    # ── Resolve vault and scan dirs ────────────────────────────────────
    vault: Path | None = None
    scan_dirs: list[Path] = []

    if args.vault_or_dir:
        p = Path(args.vault_or_dir).expanduser().resolve()
        if DEFAULT_VAULT and not p.is_absolute():
            vault = DEFAULT_VAULT
            scan_dirs = [vault / args.vault_or_dir]
        elif p.is_dir():
            vault = p
            scan_dirs = [vault / d for d in args.extra_dirs] if args.extra_dirs else [vault]
        else:
            if DEFAULT_VAULT:
                vault = DEFAULT_VAULT
                scan_dirs = [vault / args.vault_or_dir]
            else:
                sys.exit(f"Path not found: {p}")
    elif DEFAULT_VAULT:
        vault = DEFAULT_VAULT
        scan_dirs = [vault]
    else:
        parser.print_help()
        sys.exit("Error: vault path required (arg or OBSIDIAN_ORPH_VAULT)")

    if not vault or not vault.is_dir():
        sys.exit(f"Vault not found: {vault}")

    if args.extra_dirs and len(scan_dirs) == 1 and scan_dirs[0] == vault:
        scan_dirs = [vault / d for d in args.extra_dirs]

    for d in scan_dirs:
        if not d.is_dir():
            sys.exit(f"Scan directory not found: {d}")

    # ── Run scan ───────────────────────────────────────────────────────
    mode_ext = "whitelist" if ONLY_EXTS else "blacklist"
    mode_dir = "whitelist" if ONLY_DIRS else "all"
    print(f"Vault:                 {vault}")
    print(f"Scanning:              {', '.join(str(d.relative_to(vault)) for d in scan_dirs)}")
    print(f"Extension mode:        {mode_ext}")
    print(f"Directory mode:        {mode_dir}")
    print(f"Excluded extensions:   {', '.join(sorted(EXCLUDE_EXTS))}")
    print(f"Excluded directories:  {', '.join(sorted(EXCLUDE_DIRS))}")
    print(f"Excluded files:        {', '.join(sorted(EXCLUDE_FILES))}")
    if ONLY_EXTS:
        print(f"Only extensions:       {', '.join(sorted(ONLY_EXTS))}")
    if ONLY_DIRS:
        print(f"Only directories:      {', '.join(sorted(ONLY_DIRS))}")

    referenced = collect_referenced_files(vault)
    print(f"Referenced (names+stems): {len(referenced)}")

    candidates = find_candidate_files(vault, scan_dirs)
    print(f"Candidate files:         {len(candidates)}")

    orphans = []
    for f in candidates:
        if f.name not in referenced and f.stem not in referenced:
            orphans.append(f.relative_to(vault))

    if orphans:
        print(f"\nFound {len(orphans)} orphaned file(s):")
        for p in sorted(orphans):
            print(f"ORPHAN: {p}")
        return 1
    else:
        print("\nNo orphaned files found.")
        return 0


if __name__ == "__main__":
    sys.exit(main())
