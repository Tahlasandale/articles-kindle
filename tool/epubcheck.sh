#!/usr/bin/env bash
# Fabrique des EPUB et les fait valider par epubcheck, qui est la seule autorité
# sur la conformité d'un EPUB. Un fichier qui passe nos tests Dart peut quand
# même être refusé par Amazon si la structure OCF est fausse.
#
# Le jar est téléchargé une fois dans tool/cache/ et réutilisé ensuite.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cache="$root/tool/cache"
version="${EPUBCHECK_VERSION:-5.4.0}"
zip_url="https://github.com/w3c/epubcheck/releases/download/v${version}/epubcheck-${version}.zip"

if ! command -v java > /dev/null 2>&1; then
  echo "epubcheck a besoin d'un JDK dans le PATH." >&2
  echo "Cette machine n'a pas de JDK système :" >&2
  echo "  export JAVA_HOME=\"\$HOME/dev/jdk17\"" >&2
  echo "  export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >&2
  exit 1
fi

mkdir -p "$cache"
jar="$(ls "$cache"/epubcheck-*.jar 2> /dev/null | head -1 || true)"

if [ -z "$jar" ]; then
  echo "Téléchargement d'epubcheck $version…"
  curl -fsSL -o "$cache/epubcheck-$version.zip" "$zip_url"
  unzip -oq "$cache/epubcheck-$version.zip" -d "$cache"
  rm -f "$cache/epubcheck-$version.zip"
  jar="$(find "$cache" -name 'epubcheck*.jar' ! -name '*sources*' ! -name '*javadoc*' | head -1)"
  if [ -z "$jar" ]; then
    echo "aucun jar trouvé dans l'archive epubcheck" >&2
    exit 1
  fi
fi

export PATH="$root/tool:$PATH"
dart run tool/validate_epubs.dart "$jar"