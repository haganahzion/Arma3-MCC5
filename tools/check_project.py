"""Static checks that catch mistakes without Arma.

1. Every function registered in a cfgFunctions*.hpp has its file on disk.
2. Every quoted mod file path in code/config (sqf, paa, ogg, ...) exists.
3. Every remoteExec / remoteExecCall target name is in an MCC remoteExec whitelist.

Usage: python3 tools/check_project.py [repo root]   (exit code 1 on any problem)
"""
import os
import re
import sys
from pathlib import Path

CODE_EXTS = (".sqf", ".hpp", ".cpp", ".ext", ".h", ".fsm", ".inc")
SKIP_DIRS = {".git", "site", "docs", "sampleMissions", "build", "tools", ".wrangler", "__pycache__"}
MOD_PREFIX = "mcc_sandbox_mod/"
PATH_ROOTS = ("mcc", "gaia", "hcam", "bon_artillery", "data", "spectator")
PATH_EXTS = ("sqf", "paa", "jpg", "ogg", "wss", "hpp", "sqs", "fsm", "p3d", "html", "ext")
WHITELIST_FILES = ("mcc/cfg/CfgRemoteExec.hpp", "mcc/cfg/CfgRemoteExecCommands.hpp",
                   "mcc/radio/cfgRemoteExec.hpp", "mcc/AAS/cfgRemoteExec.hpp")

PATH_RE = re.compile(r'(?:["\']|["\'][\\/]?mcc_sandbox_mod[\\/]|%%1)((?:%s)[\\/][A-Za-z0-9_\\/.\- ]+?\.(?:%s))\b'
                     % ("|".join(PATH_ROOTS), "|".join(PATH_EXTS)), re.I)
REMOTE_RE = re.compile(r'remoteExec(?:Call)?\s*\[\s*"(\w+)"', re.I)
CLASS_RE = re.compile(r"\bclass\s+(\w+)")


def norm(p: str) -> str:
    return p.replace("\\", "/").replace("//", "/").lstrip("/")


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    return re.sub(r"(?m)^\s*//.*$", "", text)


def mcc_mode_only(text: str) -> str:
    """Keep the MCCMODE (mod) side of #ifdef MCCMODE / #else blocks."""
    out, keep = [], [True]
    for line in text.split("\n"):
        s = line.strip()
        if s.startswith("#ifdef"):
            keep.append(True)
            continue
        if s.startswith("#ifndef"):
            keep.append(False)
            continue
        if s.startswith("#else"):
            keep[-1] = not keep[-1]
            continue
        if s.startswith("#endif"):
            if len(keep) > 1:
                keep.pop()
            continue
        if all(keep):
            out.append(line)
    return "\n".join(out)


def code_files(root: Path):
    for dp, dn, fn in os.walk(root):
        dn[:] = [d for d in dn if d not in SKIP_DIRS]
        for f in fn:
            if f.lower().endswith(CODE_EXTS):
                yield Path(dp) / f


def file_index(root: Path) -> set:
    idx = set()
    for dp, dn, fn in os.walk(root):
        dn[:] = [d for d in dn if d != ".git"]
        for f in fn:
            idx.add(norm(str((Path(dp) / f).relative_to(root))).lower())
    return idx


def registered_functions(text: str, tag_default: str) -> dict:
    """Parse one cfgFunctions file: {TAG_fnc_name: path}."""
    text = mcc_mode_only(strip_comments(text))
    m = re.search(r'tag\s*=\s*"(\w+)"', text)
    tag = m.group(1) if m else tag_default
    tokens = re.findall(r'class\s+\w+|\{|\}|file\s*=\s*"[^"]*"|ext\s*=\s*"[^"]*"', text)
    root = {"name": None, "kids": [], "file": None, "ext": None}
    stack, pending = [root], None
    for tk in tokens:
        if tk.startswith("class"):
            pending = tk.split()[1]
        elif tk == "{":
            node = {"name": pending, "kids": [], "file": None, "ext": None}
            stack[-1]["kids"].append(node)
            stack.append(node)
            pending = None
        elif tk == "}":
            if len(stack) > 1:
                stack.pop()
        elif tk.startswith("file"):
            stack[-1]["file"] = tk.split('"')[1]
        elif tk.startswith("ext"):
            stack[-1]["ext"] = tk.split('"')[1]
    found = {}

    def walk(node, folder):
        for k in node["kids"]:
            if k["kids"]:
                walk(k, k["file"] or folder)
            elif k["name"] and k["name"].lower() != tag.lower():
                path = k["file"] or "%s/fn_%s%s" % (folder or "?", k["name"], k["ext"] or ".sqf")
                found["%s_fnc_%s" % (tag, k["name"])] = norm(path)

    walk(root, None)
    return found


def check_functions(root: Path, idx: set) -> list:
    problems = []
    for p in code_files(root):
        if not (p.name.lower().startswith("cfgfunctions") and p.suffix.lower() == ".hpp"):
            continue
        default = "GAIA" if "gaia" in str(p).lower() else "MCC"
        text = p.read_text(encoding="utf-8", errors="replace")
        for fnc, path in registered_functions(text, default).items():
            rel = path.lower()
            if rel.startswith(MOD_PREFIX):
                rel = rel[len(MOD_PREFIX):]
            if rel not in idx:
                problems.append("missing function file: %s -> %s (%s)" % (fnc, path, p.relative_to(root)))
    return problems


def check_paths(root: Path, idx: set) -> list:
    problems = []
    for p in code_files(root):
        for n, line in enumerate(p.read_text(encoding="utf-8", errors="replace").split("\n"), 1):
            if line.strip().startswith("//"):
                continue
            for m in PATH_RE.finditer(line):
                path = norm(m.group(1)).lower()
                if path.startswith(MOD_PREFIX):
                    path = path[len(MOD_PREFIX):]
                if path not in idx:
                    problems.append("missing file: %s (%s:%d)" % (m.group(1), p.relative_to(root), n))
    return problems


def whitelist(root: Path) -> set:
    names = set()
    for rel in WHITELIST_FILES:
        f = root / rel
        if f.exists():
            names |= {c.lower() for c in CLASS_RE.findall(strip_comments(f.read_text(encoding="utf-8", errors="replace")))}
    return names


def check_remote(root: Path) -> list:
    allowed = whitelist(root)
    problems = []
    for p in code_files(root):
        if p.suffix.lower() != ".sqf":
            continue
        text = strip_comments(p.read_text(encoding="utf-8", errors="replace"))
        for m in REMOTE_RE.finditer(text):
            if m.group(1).lower() not in allowed:
                line = text.count("\n", 0, m.start()) + 1
                problems.append("remoteExec target not whitelisted: %s (%s:~%d)" % (m.group(1), p.relative_to(root), line))
    return problems


def main(argv) -> int:
    root = Path(argv[1] if len(argv) > 1 else ".").resolve()
    idx = file_index(root)
    problems = check_functions(root, idx) + check_paths(root, idx) + check_remote(root)
    for x in problems:
        print(x)
    print("%d problems" % len(problems))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
