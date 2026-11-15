#!/usr/bin/env python3
"""Build the MCC 5 wiki as one self-contained HTML page from docs/wiki/*.md.

Usage: python3 tools/build_wiki_html.py <output.html>
Pages are routed by hash (#installation, #gaia--vehicles for a section). Markdown is converted to HTML here
(small built-in converter), so the page needs no external scripts. The banner comes from docs/mcc5_banner.png.
"""
import base64, io, json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WIKI = os.path.join(ROOT, "docs", "wiki")


def banner_data_uri():
    path = os.path.join(ROOT, "docs", "mcc5_banner.png")
    try:
        from PIL import Image
        buf = io.BytesIO()
        Image.open(path).convert("RGB").save(buf, "JPEG", quality=82)
        return "data:image/jpeg;base64," + base64.b64encode(buf.getvalue()).decode()
    except Exception:
        with open(path, "rb") as fh:
            return "data:image/png;base64," + base64.b64encode(fh.read()).decode()


def load_pages():
    order = []
    with open(os.path.join(WIKI, "_sidebar.md"), encoding="utf-8") as fh:
        for m in re.finditer(r"\[([^\]]+)\]\(([^)]+)\.md\)", fh.read()):
            order.append((m.group(2), m.group(1)))
    pages = {}
    for slug, _ in order:
        with open(os.path.join(WIKI, slug + ".md"), encoding="utf-8") as fh:
            pages[slug] = fh.read()
    return order, pages


def _esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def _inline(s):
    """Inline markdown: code, links, bold, italic. Text is escaped first."""
    codes = []

    def keep(m):
        codes.append("<code>" + _esc(m.group(1)) + "</code>")
        return "\x00%d\x00" % (len(codes) - 1)

    s = re.sub(r"`([^`]+)`", keep, s)
    s = _esc(s)
    s = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)", lambda m: '<a href="%s">%s</a>' % (m.group(2).replace('"', "%22"), m.group(1)), s)
    s = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", s)
    s = re.sub(r"(?<![\w*])\*([^*\n]+)\*(?![\w*])", r"<em>\1</em>", s)
    s = re.sub(r"(?<![\w_])_([^_\n]+)_(?![\w_])", r"<em>\1</em>", s)
    return re.sub(r"\x00(\d+)\x00", lambda m: codes[int(m.group(1))], s)


def md_to_html(md):
    """Small Markdown renderer for the wiki: headings, paragraphs, nested lists, tables, code fences,
    blockquotes, horizontal rules and inline formatting."""
    lines = md.replace("\r\n", "\n").split("\n")
    out, i, n = [], 0, len(lines)
    para = []

    def flush():
        if para:
            out.append("<p>" + _inline(" ".join(para)) + "</p>")
            para.clear()

    while i < n:
        line = lines[i]
        if line.startswith("```"):
            flush()
            i += 1
            buf = []
            while i < n and not lines[i].startswith("```"):
                buf.append(lines[i])
                i += 1
            out.append("<pre><code>" + _esc("\n".join(buf)) + "</code></pre>")
            i += 1
            continue
        m = re.match(r"^(#{1,6})\s+(.*)$", line)
        if m:
            flush()
            lvl = len(m.group(1))
            out.append("<h%d>%s</h%d>" % (lvl, _inline(m.group(2).strip()), lvl))
            i += 1
            continue
        if re.match(r"^\s*(---|\*\*\*)\s*$", line):
            flush()
            out.append("<hr>")
            i += 1
            continue
        if line.startswith(">"):
            flush()
            buf = []
            while i < n and lines[i].startswith(">"):
                buf.append(lines[i][1:].lstrip())
                i += 1
            out.append("<blockquote>" + md_to_html("\n".join(buf)) + "</blockquote>")
            continue
        if line.lstrip().startswith("|") and i + 1 < n and re.match(r"^\s*\|?\s*:?-{2,}", lines[i + 1]):
            flush()
            def cells(row):
                row = row.strip().strip("|")
                return [c.strip() for c in re.split(r"(?<!\\)\|", row)]
            head = cells(line)
            i += 2
            rows = []
            while i < n and lines[i].lstrip().startswith("|"):
                rows.append(cells(lines[i]))
                i += 1
            html = "<table><thead><tr>" + "".join("<th>%s</th>" % _inline(c) for c in head) + "</tr></thead><tbody>"
            for r in rows:
                html += "<tr>" + "".join("<td>%s</td>" % _inline(c.replace("\\|", "|")) for c in r) + "</tr>"
            out.append(html + "</tbody></table>")
            continue
        if re.match(r"^\s*([-*+]|\d+[.)])\s+", line):
            flush()
            block = []
            while i < n and (re.match(r"^\s*([-*+]|\d+[.)])\s+", lines[i]) or (lines[i].startswith("  ") and lines[i].strip())):
                block.append(lines[i])
                i += 1
            out.append(_list(block))
            continue
        if not line.strip():
            flush()
            i += 1
            continue
        para.append(line.strip())
        i += 1
    flush()
    return "\n".join(out)


def _list(block):
    """Render list lines (with 2+ space indentation for nesting)."""
    def indent(l):
        return len(l) - len(l.lstrip(" "))
    base = indent(block[0])
    ordered = bool(re.match(r"^\s*\d+[.)]\s", block[0]))
    tag = "ol" if ordered else "ul"
    items, cur = [], None
    for l in block:
        if indent(l) <= base + 1 and re.match(r"^\s*([-*+]|\d+[.)])\s+", l):
            cur = [re.sub(r"^\s*([-*+]|\d+[.)])\s+", "", l)]
            items.append(cur)
        elif cur is not None:
            cur.append(l)
    html = "<%s>" % tag
    for it in items:
        text, rest = it[0], it[1:]
        sub = [r for r in rest if re.match(r"^\s*([-*+]|\d+[.)])\s+", r)]
        cont = [r.strip() for r in rest if r not in sub]
        body = _inline(" ".join([text] + cont))
        if sub:
            body += _list(sub)
        html += "<li>" + body + "</li>"
    return html + "</%s>" % tag


TEMPLATE = r"""<title>MCC 5 Wiki</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Saira+Condensed:wght@600;700&family=IBM+Plex+Sans:ital,wght@0,400;0,600;1,400&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
/* Layout: field-manual wiki. Sticky contents rail on the left, one page of text on the right. */
:root {
  --bg: #f3f2ec; --panel: #e8e6dc; --fg: #1f2320; --muted: #5d625b; --line: #cfccbf;
  --accent: #b9721b; --accent-ink: #8a5210; --code-bg: #e2dfd3; --link: #8a5210;
  --display: "Saira Condensed", "Arial Narrow", Arial, sans-serif;
  --body: "IBM Plex Sans", "Segoe UI", Arial, sans-serif;
  --mono: "IBM Plex Mono", Consolas, "Courier New", monospace;
}
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) {
  --bg: #161917; --panel: #1e221f; --fg: #e6e4da; --muted: #a3a79c; --line: #333833;
  --accent: #e9a23b; --accent-ink: #f0b65e; --code-bg: #232823; --link: #f0b65e; color-scheme: dark } }
:root[data-theme="dark"] {
  --bg: #161917; --panel: #1e221f; --fg: #e6e4da; --muted: #a3a79c; --line: #333833;
  --accent: #e9a23b; --accent-ink: #f0b65e; --code-bg: #232823; --link: #f0b65e; color-scheme: dark }
body { background: var(--bg); color: var(--fg); font-family: var(--body); font-size: 16px; line-height: 1.65; }
.wrap { max-width: 1180px; margin: 0 auto; padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px)); padding-block: 0 48px; }
.banner { display: block; width: 100%; max-width: 100%; aspect-ratio: 4 / 1; object-fit: cover; border-bottom: 3px solid var(--accent); }
.topbar { display: flex; flex-wrap: wrap; gap: 12px; align-items: center; justify-content: space-between; padding-block: 14px; border-bottom: 1px solid var(--line); }
.brand { font-family: var(--display); font-size: 1.5rem; letter-spacing: 0.04em; text-transform: uppercase; }
.brand b { color: var(--accent); }
.search { flex: 1 1 240px; max-width: 360px; }
.search input { width: 100%; box-sizing: border-box; padding: 8px 12px; border: 1px solid var(--line); border-radius: 4px; background: var(--panel); color: var(--fg); font: inherit; }
.search input:focus-visible, a:focus-visible, summary:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }
.layout { display: grid; grid-template-columns: 240px minmax(0, 1fr); gap: 40px; padding-top: 24px; }
nav.toc { position: sticky; top: calc(env(safe-area-inset-top, 0px) + 12px); align-self: start; max-height: calc(100vh - 24px); overflow: auto; }
nav.toc ol { list-style: none; margin: 0; padding: 0; display: grid; gap: 2px; }
nav.toc a { display: block; padding: 6px 10px; border-left: 3px solid transparent; color: var(--fg); text-decoration: none; font-size: 0.95rem; }
nav.toc a:hover { background: var(--panel); }
nav.toc a[aria-current="page"] { border-left-color: var(--accent); background: var(--panel); font-weight: 600; }
.toc-label { font-family: var(--display); text-transform: uppercase; letter-spacing: 0.08em; color: var(--muted); font-size: 0.85rem; margin: 0 0 8px 10px; }
details.toc-mobile { display: none; }
article { min-width: 0; max-width: 72ch; }
article h1 { font-family: var(--display); font-size: 2.4rem; line-height: 1.1; letter-spacing: 0.02em; text-transform: uppercase; margin: 0 0 18px; text-wrap: balance; }
article h2 { font-family: var(--display); font-size: 1.55rem; letter-spacing: 0.03em; margin: 34px 0 10px; padding-top: 10px; border-top: 1px solid var(--line); text-wrap: balance; }
article h3 { font-size: 1.1rem; margin: 24px 0 8px; }
article a { color: var(--link); text-underline-offset: 2px; }
article code { font-family: var(--mono); font-size: 0.88em; background: var(--code-bg); padding: 1px 5px; border-radius: 3px; }
article pre { background: var(--code-bg); padding: 12px 14px; border-radius: 4px; overflow-x: auto; }
article pre code { background: none; padding: 0; }
article blockquote { margin: 16px 0; padding: 8px 14px; border-left: 3px solid var(--accent); background: var(--panel); color: var(--fg); }
article blockquote p { margin: 6px 0; }
.table-wrap { overflow-x: auto; margin: 14px 0; }
article table { border-collapse: collapse; font-size: 0.92rem; min-width: 100%; }
article th, article td { border-bottom: 1px solid var(--line); padding: 7px 10px; text-align: left; vertical-align: top; }
article th { font-family: var(--display); letter-spacing: 0.05em; text-transform: uppercase; font-size: 0.85rem; color: var(--muted); }
article ul, article ol { padding-left: 1.4em; }
article li { margin: 3px 0; }
.pager { display: flex; justify-content: space-between; gap: 12px; margin-top: 40px; padding-top: 16px; border-top: 1px solid var(--line); flex-wrap: wrap; }
.pager a { color: var(--link); text-decoration: none; font-weight: 600; }
.results { list-style: none; padding: 0; display: grid; gap: 10px; }
.results li { padding: 10px 12px; background: var(--panel); border-radius: 4px; }
.results small { display: block; color: var(--muted); }
footer { margin-top: 48px; color: var(--muted); font-size: 0.85rem; }
@media (max-width: 820px) {
  .layout { grid-template-columns: minmax(0, 1fr); gap: 16px; }
  nav.toc { display: none; }
  details.toc-mobile { display: block; background: var(--panel); border-radius: 4px; padding: 8px 12px; }
  details.toc-mobile summary { cursor: pointer; font-family: var(--display); text-transform: uppercase; letter-spacing: 0.06em; }
  details.toc-mobile a { display: block; padding: 6px 0; color: var(--fg); text-decoration: none; }
  article h1 { font-size: 1.9rem; }
}
@media (prefers-reduced-motion: reduce) { * { scroll-behavior: auto !important; } }
</style>
<img class="banner" src="__BANNER__" alt="MCC 5, Arma 3 Mission Control Center: mission making the easy way">
<div class="wrap">
  <div class="topbar">
    <div class="brand">MCC <b>5</b> Wiki</div>
    <div class="search"><label for="q" class="toc-label" style="display:none">Search</label><input id="q" type="search" placeholder="Search the wiki" aria-label="Search the wiki"></div>
  </div>
  <div class="layout">
    <nav class="toc" aria-label="Wiki pages"><p class="toc-label">Pages</p><ol id="toc"></ol></nav>
    <div style="min-width:0">
      <details class="toc-mobile" id="tocm"><summary>Pages</summary><div id="tocmList"></div></details>
      <article id="page"></article>
      <div class="pager" id="pager"></div>
      <footer>MCC Sandbox 5 is built on MCC Sandbox by Shay_gman &amp; Spirit. Free under the GPL-3.0. Discord: <a href="https://discord.gg/bxwX5EkMEf">discord.gg/bxwX5EkMEf</a>.</footer>
    </div>
  </div>
</div>
<script type="application/json" id="wiki-data">__DATA__</script>
<script>
(function () {
  var data = JSON.parse(document.getElementById("wiki-data").textContent);
  var order = data.order, pages = data.pages, html = data.html;
  var slugs = order.map(function (o) { return o[0]; });
  function slugify(t) { return t.toLowerCase().replace(/<[^>]+>/g, "").replace(/[^a-z0-9 -]/g, "").trim().replace(/\s+/g, "-"); }
  function linkFor(href) {
    var m = /^([a-z0-9-]+)\.md(?:#([a-z0-9-]+))?$/i.exec(href);
    if (m) return "#" + m[1] + (m[2] ? "--" + m[2] : "");
    var a = /^#([a-z0-9-]+)$/i.exec(href);
    return a ? null : href;
  }
  function render(md, slug) {
    var box = document.getElementById("page");
    box.innerHTML = md;
    box.querySelectorAll("h1,h2,h3").forEach(function (h) { h.id = slugify(h.textContent); });
    box.querySelectorAll("a[href]").forEach(function (a) {
      var href = a.getAttribute("href");
      var local = /^#([a-z0-9-]+)$/i.exec(href);
      if (local) { a.setAttribute("href", "#" + slug + "--" + local[1]); return; }
      var to = linkFor(href);
      if (to && to.charAt(0) === "#") { a.setAttribute("href", to); }
      else if (/^https?:/i.test(href)) { a.target = "_blank"; a.rel = "noopener"; }
    });
    box.querySelectorAll("table").forEach(function (t) {
      var w = document.createElement("div"); w.className = "table-wrap"; t.parentNode.insertBefore(w, t); w.appendChild(t);
    });
  }
  function buildToc(current) {
    var ol = document.getElementById("toc"), ml = document.getElementById("tocmList");
    ol.innerHTML = ""; ml.innerHTML = "";
    order.forEach(function (o) {
      var li = document.createElement("li"), a = document.createElement("a");
      a.href = "#" + o[0]; a.textContent = o[1];
      if (o[0] === current) a.setAttribute("aria-current", "page");
      li.appendChild(a); ol.appendChild(li);
      var m = a.cloneNode(true); ml.appendChild(m);
    });
  }
  function pager(slug) {
    var i = slugs.indexOf(slug), p = document.getElementById("pager");
    p.innerHTML = "";
    if (i > 0) { var a = document.createElement("a"); a.href = "#" + slugs[i - 1]; a.textContent = "← " + order[i - 1][1]; p.appendChild(a); } else { p.appendChild(document.createElement("span")); }
    if (i >= 0 && i < slugs.length - 1) { var b = document.createElement("a"); b.href = "#" + slugs[i + 1]; b.textContent = order[i + 1][1] + " →"; p.appendChild(b); }
  }
  function search(q) {
    q = q.trim().toLowerCase();
    var box = document.getElementById("page");
    var hits = [];
    order.forEach(function (o) {
      var text = pages[o[0]], low = text.toLowerCase(), at = low.indexOf(q);
      if (at >= 0) {
        var snip = text.slice(Math.max(0, at - 60), at + 120).replace(/[#*`|>\[\]]/g, " ").replace(/\s+/g, " ");
        hits.push([o, snip]);
      }
    });
    box.innerHTML = "<h1>Search</h1><p>" + hits.length + " page(s) mention “" + q.replace(/[&<]/g, "") + "”.</p>";
    var ul = document.createElement("ul"); ul.className = "results";
    hits.forEach(function (h) {
      var li = document.createElement("li"), a = document.createElement("a");
      a.href = "#" + h[0][0]; a.textContent = h[0][1];
      var s = document.createElement("small"); s.textContent = "…" + h[1] + "…";
      li.appendChild(a); li.appendChild(s); ul.appendChild(li);
    });
    box.appendChild(ul);
    document.getElementById("pager").innerHTML = "";
  }
  function show() {
    var h = (location.hash || "").replace(/^#/, "");
    var parts = h.split("--"), slug = parts[0], sec = parts[1];
    if (slugs.indexOf(slug) < 0) { slug = slugs[0]; sec = null; }
    render(html[slug], slug);
    buildToc(slug); pager(slug);
    document.getElementById("tocm").open = false;
    var target = sec ? document.getElementById(sec) : null;
    if (target) { target.scrollIntoView(); } else { window.scrollTo(0, 0); }
    var title = order[slugs.indexOf(slug)][1];
    document.title = (slug === slugs[0] ? "MCC 5 Wiki" : title + " | MCC 5 Wiki");
  }
  var q = document.getElementById("q"), timer = null;
  q.addEventListener("input", function () {
    clearTimeout(timer);
    timer = setTimeout(function () { if (q.value.trim().length >= 2) { search(q.value); } else { show(); } }, 180);
  });
  window.addEventListener("hashchange", function () { q.value = ""; show(); });
  show();
})();
</script>
"""


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "build", "wiki.html")
    order, pages = load_pages()
    rendered = {k: md_to_html(v) for k, v in pages.items()}
    data = json.dumps({"order": order, "pages": pages, "html": rendered}).replace("</", "<\\/")
    html = TEMPLATE.replace("__BANNER__", banner_data_uri()).replace("__DATA__", data)
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    with open(out, "w", encoding="utf-8") as fh:
        fh.write(html)
    print("wrote %s (%d pages, %.0f KB)" % (out, len(order), len(html) / 1024))


if __name__ == "__main__":
    main()
