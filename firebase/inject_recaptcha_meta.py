#!/usr/bin/env python3
"""Inject RECAPTCHA_SITE_KEY into hosting index.html meta tag (HTML-escaped)."""
import html
import os
import re
import sys
from pathlib import Path

_META_RE = re.compile(
    r'(<meta\s+name="pf-recaptcha-site-key"\s+content=")([^"]*)("\s*/?>)',
    re.IGNORECASE | re.DOTALL,
)


def main() -> None:
    if len(sys.argv) != 2:
        print("usage: inject_recaptcha_meta.py <path/to/hosting/index.html>", file=sys.stderr)
        sys.exit(2)
    path = Path(sys.argv[1])
    key = os.environ.get("RECAPTCHA_SITE_KEY", "").strip()
    if not key:
        print("inject_recaptcha_meta: RECAPTCHA_SITE_KEY empty, skipping", file=sys.stderr)
        return
    text = path.read_text(encoding="utf-8")
    esc = html.escape(key, quote=True)

    def repl(m):
        return f'{m.group(1)}{esc}{m.group(3)}'

    new_text, n = _META_RE.subn(repl, text, count=1)
    if n != 1:
        print(
            "inject_recaptcha_meta: pf-recaptcha-site-key meta not found or pattern mismatch",
            file=sys.stderr,
        )
        sys.exit(1)
    path.write_text(new_text, encoding="utf-8")
    print("inject_recaptcha_meta: updated", path)


if __name__ == "__main__":
    main()
