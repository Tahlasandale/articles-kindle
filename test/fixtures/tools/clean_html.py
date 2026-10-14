#!/usr/bin/env python3
"""Nettoie les fixtures HTML figées avant de les écrire dans le dépôt.

Objectif : retirer le bruit qui n'apporte rien à l'extraction de texte
(<script>, <noscript>, iframes, preconnect/preload, trackers) SANS toucher
au contenu éditorial de l'article.

Usage :
    python3 clean_html.py <fichier_source> <fichier_dest>
    python3 clean_html.py --report <fichier_source>   # stats uniquement
"""

import re
import sys
from html.parser import HTMLParser

MAX_BYTES = 2 * 1024 * 1024  # 2 Mo

# Éléments dont le contenu et les balises sont supprimés entièrement.
DROP_TREE_TAGS = {"script", "noscript", "iframe", "object", "embed", "applet"}

# <link> dont on retire la balise (auto-close) selon son rel.
DROP_LINK_RELS = {"preconnect", "preload", "dns-prefetch", "prerender", "prefetch", "modulepreload", "manifest"}

# Domaines de tracking / publicité connus.
TRACKER_DOMAINS = (
    "googletagmanager.com",
    "google-analytics.com",
    "analytics.google.com",
    "doubleclick.net",
    "googlesyndication.com",
    "googleadservices.com",
    "adservice.google.com",
    "connect.facebook.net",
    "connect.facebook.com",
    "ads-twitter.com",
    "static.hotjar.com",
    "script.hotjar.com",
    "cdn.segment.com",
    "cdn.amplitude.com",
    "snap.licdn.com",
    "match.adsrvr.org",
    "app.termina.io",
    "yandex.ru/metrika",
)

VOID_TAGS = {
    "area", "base", "br", "col", "embed", "hr", "img", "input",
    "link", "meta", "param", "source", "track", "wbr",
}

# src/srcset -> on retire l'attribut entier si le domaine est un tracker.
TRACKABLE_ATTRS = ("src", "srcset", "data-src", "data-lazy-src", "poster")

ATTR_RE = re.compile(r"""([a-zA-Z_:][-a-zA-Z0-9_:.]*)\s*=\s*("([^"]*)"|'([^']*)'|([^\s"'>`]+))""")


def is_tracker(value: str) -> bool:
    low = value.lower()
    return any(d in low for d in TRACKER_DOMAINS)


class Cleaner(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.out = []
        self.skip_depth = 0
        self.dropped_scripts = 0
        self.dropped_noscript = 0
        self.dropped_iframes = 0
        self.dropped_links = 0
        self.dropped_trackers = 0
        self.removed_preload = 0
        self.dropped_comments = 0

    # -- helpers ---------------------------------------------------------
    def _clean_attrs(self, attrs):
        cleaned = []
        for name, value in attrs:
            n = name.lower()
            v = value or ""
            if n in TRACKABLE_ATTRS and is_tracker(v):
                self.dropped_trackers += 1
                continue
            cleaned.append((name, v))
        return cleaned

    def _emit_tag(self, tag, attrs, self_closing=False):
        parts = [tag]
        for name, value in attrs:
            if value == "":
                parts.append(name)
            else:
                # Dans une valeur d'attribut, seuls & et " doivent être échappés ;
                # on ne touche pas à '<' / '>' pour rester byte-identique à la source.
                escaped = value.replace("&", "&amp;").replace('"', "&quot;")
                parts.append('%s="%s"' % (name, escaped))
        body = " ".join(parts)
        if self_closing or tag in VOID_TAGS:
            self.out.append("<%s/>" % body)
        else:
            self.out.append("<%s>" % body)

    # -- HTMLParser API --------------------------------------------------
    def handle_starttag(self, tag, attrs):
        tag = tag.lower()
        if self.skip_depth:
            if tag in DROP_TREE_TAGS:
                self.skip_depth += 1
            return
        if tag in DROP_TREE_TAGS:
            if tag == "script":
                self.dropped_scripts += 1
            elif tag == "noscript":
                self.dropped_noscript += 1
            else:
                self.dropped_iframes += 1
            self.skip_depth = 1
            return
        if tag == "link":
            d = {k.lower(): (v or "") for k, v in attrs}
            rels = set(d.get("rel", "").lower().split())
            if rels & DROP_LINK_RELS:
                self.removed_preload += 1
                return
            if is_tracker(d.get("href", "")):
                self.dropped_trackers += 1
                return
            self.dropped_links += 1 if False else 0
        self._emit_tag(tag, self._clean_attrs(attrs))

    def handle_startendtag(self, tag, attrs):
        tag = tag.lower()
        if self.skip_depth:
            return
        if tag in DROP_TREE_TAGS:
            if tag == "script":
                self.dropped_scripts += 1
            elif tag == "noscript":
                self.dropped_noscript += 1
            else:
                self.dropped_iframes += 1
            return
        if tag == "link":
            d = {k.lower(): (v or "") for k, v in attrs}
            rels = set(d.get("rel", "").lower().split())
            if rels & DROP_LINK_RELS or is_tracker(d.get("href", "")):
                self.removed_preload += 1
                return
        self._emit_tag(tag, self._clean_attrs(attrs), self_closing=True)

    def handle_endtag(self, tag):
        tag = tag.lower()
        if self.skip_depth:
            if tag in DROP_TREE_TAGS:
                self.skip_depth -= 1
            return
        if tag in DROP_TREE_TAGS or tag in VOID_TAGS:
            return
        self.out.append("</%s>" % tag)

    def handle_data(self, data):
        if self.skip_depth:
            return
        self.out.append(data.replace("&", "&amp;").replace("<", "&lt;"))

    def handle_entityref(self, name):  # convert_charrefs=True -> peu utilisé
        if not self.skip_depth:
            self.out.append("&%s;" % name)

    def handle_charref(self, name):
        if not self.skip_depth:
            self.out.append("&#%s;" % name)

    def handle_comment(self, data):
        if self.skip_depth:
            return
        # Les commentaires font partie de la page telle qu'elle a été servie
        # (certains sites en utilisent pour du balisage), SAUF :
        #  - les commentaires conditionnels IE, code mort ;
        #  - les commentaires qui "avalent" des <script>/<iframe>/<noscript>
        #    (commentaire non fermé => le parseur HTML voit ces balises).
        low = data.lower()
        if low.lstrip().startswith("[if ") or re.search(r"<(script|iframe|noscript)\b", low):
            self.dropped_comments += 1
            return
        self.out.append("<!--%s-->" % data)

    def handle_decl(self, decl):
        if not self.skip_depth:
            self.out.append("<!%s>" % decl)

    def handle_pi(self, data):
        pass

    def unknown_decl(self, data):
        if not self.skip_depth:
            self.out.append("<![%s]>" % data)


BASE64_IMG_RE = re.compile(r'(src|poster|srcset|data-src)\s*=\s*"data:image/[^"]{200,}?"', re.I)
COMMENT_RE = re.compile(r"<!--.*?-->", re.S)


def strip_base64_images(html: str) -> str:
    return BASE64_IMG_RE.sub(r'\1=""', html)


def strip_comments(html: str) -> str:
    return COMMENT_RE.sub("", html)


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    src, dest = argv[1], argv[2]
    with open(src, "rb") as fh:
        raw = fh.read()
    text = raw.decode("utf-8", errors="replace")

    parser = Cleaner()
    parser.feed(text)
    parser.close()
    html = "".join(parser.out)

    # Garde-fous : rien ne doit dépasser 2 Mo sur disque.
    steps = []
    if len(html.encode("utf-8")) > MAX_BYTES:
        html = strip_base64_images(html)
        steps.append("base64-stripped")
    if len(html.encode("utf-8")) > MAX_BYTES:
        html = strip_comments(html)
        steps.append("comments-stripped")
    if len(html.encode("utf-8")) > MAX_BYTES:
        # Dernier recours : on plafonne proprement plutôt que d'écrire un fichier interdit.
        html = html.encode("utf-8")[:MAX_BYTES].decode("utf-8", errors="ignore")
        steps.append("truncated")

    with open(dest, "w", encoding="utf-8") as fh:
        fh.write(html)

    print(
        "%s | %d -> %d o | script:%d noscript:%d iframe:%d preload-link:%d tracker-attr:%d junk-comment:%d%s"
        % (
            dest.rsplit("/", 1)[-1],
            len(raw),
            len(html.encode("utf-8")),
            parser.dropped_scripts,
            parser.dropped_noscript,
            parser.dropped_iframes,
            parser.removed_preload,
            parser.dropped_trackers,
            parser.dropped_comments,
            (" | " + ",".join(steps)) if steps else "",
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))