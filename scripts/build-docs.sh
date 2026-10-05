#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--offline] [--out DIR]" >&2
  exit 1
}

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/site"
OFFLINE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offline) OFFLINE=true; shift ;;
    --out) [[ $# -ge 2 ]] || usage; OUT="$2"; shift 2 ;;
    *) usage ;;
  esac
done

CDN="https://cdn.usebruno.com/api-docs"
GIT_URL="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"

# The Bruno CLI parses every folder and .yml file in the collection root, so
# non-collection folders would show up in the docs. Build from a clean copy,
# which also keeps private environments out of the published page.
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
rsync -a \
  --include environments/Public.yml --exclude 'environments/*' \
  --exclude .git --exclude .github --exclude site \
  --exclude scripts --exclude branding --exclude node_modules \
  "$ROOT/" "$STAGE/"

mkdir -p "$OUT"
(cd "$STAGE" && bru docs generate --envs Public -o "$OUT/index.html")

cp "$ROOT/branding/logo.png" "$ROOT/branding/theme.css" "$OUT/"

if $OFFLINE; then
  curl -sfL "$CDN/api-docs.js" -o "$OUT/api-docs.js"
  curl -sfL "$CDN/api-docs.css" -o "$OUT/api-docs.css"
  ASSET_BASE=""
else
  ASSET_BASE="$CDN/"
fi

python3 - "$OUT/index.html" "$ASSET_BASE" "$GIT_URL" <<'EOF'
import json, re, sys

path, asset_base, git_url = sys.argv[1:]
html = open(path, encoding="utf-8").read()

html = html.replace(
    '<link rel="stylesheet" href="https://cdn.usebruno.com/api-docs/api-docs.css">',
    f'<link rel="stylesheet" href="{asset_base}api-docs.css">\n'
    '    <link rel="stylesheet" href="theme.css">\n'
    '    <link rel="icon" href="logo.png">',
)
html = html.replace(
    '<script src="https://cdn.usebruno.com/api-docs/api-docs.js">',
    f'<script src="{asset_base}api-docs.js">',
)

options = 'logo: "logo.png",'
if git_url:
    html = re.sub(r'\s*gitCollectionUrl:[^\n]*', '', html)
    options += f'\n            gitCollectionUrl: {json.dumps(git_url)},'
html, count = re.subn(
    r'(opencollection: collectionData,)',
    lambda m: f'{m.group(1)}\n            {options}',
    html,
)
if count != 1:
    sys.exit("Could not inject branding: generated HTML format changed")

open(path, "w", encoding="utf-8").write(html)
EOF

echo "Documentation built at $OUT/index.html"
