#!/bin/sh
# fetch-msvc.sh MANIFEST.json DEST PACKAGE-ID...: download the VSIX payloads of Visual
# Studio installer packages (en-US resources), check their sha256, unpack Contents/
# into DEST. MIRROR=DIR takes the payloads from a msvc-backup DIR instead.
# Downloading means accepting the Visual Studio license terms.
set -eu
man=$1 dest=$2; shift 2
cache=${CACHE:-/tmp/vsix}
mkdir -p "$cache" "$dest"
for id in "$@"; do
  jq -r --arg id "$id" '.packages[] | select(.id == $id and (.language == null or .language == "en-US"))
    | .payloads[] | "\(.sha256) \(.url) \(.fileName)"' "$man" > "$cache/list"
  [ -s "$cache/list" ] || { echo "fetch-msvc: no package $id" >&2; exit 1; }
  while read -r sha url name; do
    f=$cache/$sha.vsix
    if [ -n "${MIRROR:-}" ]; then cp "$MIRROR/packages/$id/$(printf '%s' "$name" | tr '\\' /)" "$f"
    elif [ ! -s "$f" ]; then curl -sSfL "$url" -o "$f"; fi
    echo "$sha  $f" | sha256sum -c --quiet - || { echo "fetch-msvc: bad sha256 $id" >&2; exit 1; }
    rm -rf "$cache/x"; unzip -qo "$f" 'Contents/*' -d "$cache/x"
    cp -R "$cache/x/Contents/." "$dest/"
  done < "$cache/list"
  echo "$id"
done
rm -rf "$cache/x" "$cache/list"
