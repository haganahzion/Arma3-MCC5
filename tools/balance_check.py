"""Bracket balance check for SQF / config files (see DEVNOTES.md).

Strips // and /* */ comments and "strings" (with "" escapes), counts [] {} (), and compares each
changed file with the same count at a git revision, so files that were already "unbalanced"
(single-quoted strings) only fail when the difference changes.

Usage:
    python3 tools/balance_check.py                 # changed + untracked files vs HEAD
    python3 tools/balance_check.py --rev origin/mcc5
    python3 tools/balance_check.py path1 path2     # given files vs HEAD
Exit code 1 when any file's balance changed.
"""
import argparse
import subprocess
import sys
from pathlib import Path

EXTENSIONS = {".sqf", ".hpp", ".cpp", ".ext", ".sqm", ".inc", ".h"}
PAIRS = (("[", "]"), ("{", "}"), ("(", ")"))


def strip_code(text: str) -> str:
    """Return text without comments and double-quoted strings."""
    out = []
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if c == "/" and i + 1 < n and text[i + 1] == "/":
            j = text.find("\n", i)
            i = n if j < 0 else j
        elif c == "/" and i + 1 < n and text[i + 1] == "*":
            j = text.find("*/", i + 2)
            i = n if j < 0 else j + 2
        elif c == '"':
            i += 1
            while i < n:
                if text[i] == '"':
                    if i + 1 < n and text[i + 1] == '"':
                        i += 2
                        continue
                    break
                i += 1
            i += 1
        else:
            out.append(c)
            i += 1
    return "".join(out)


def balance(text: str) -> tuple:
    """Open minus close count for each bracket pair."""
    code = strip_code(text)
    return tuple(code.count(o) - code.count(c) for o, c in PAIRS)


def git(*args: str) -> str:
    return subprocess.run(["git", *args], capture_output=True, text=True, encoding="utf-8",
                          errors="replace").stdout


def changed_files(rev: str) -> list:
    names = git("diff", "--name-only", rev).splitlines()
    names += git("ls-files", "--others", "--exclude-standard").splitlines()
    return sorted({n for n in names if Path(n).suffix.lower() in EXTENSIONS and Path(n).exists()})


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="*")
    ap.add_argument("--rev", default="HEAD")
    a = ap.parse_args()
    files = a.files or changed_files(a.rev)
    bad = 0
    for f in files:
        now = balance(Path(f).read_text(encoding="utf-8", errors="replace"))
        old_text = git("show", f"{a.rev}:{f}")
        old = balance(old_text) if old_text else (0, 0, 0)
        status = "ok" if now == old else "CHANGED"
        if now != old:
            bad += 1
        print(f"{status:8} {f}  []{{}}() now {now} was {old}")
    print(f"{len(files)} files, {bad} changed balance")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
