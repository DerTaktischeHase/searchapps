#!/bin/sh
# searchapps: sucht nach Programmen/Commands im PATH (case-insensitive)
# Usage: searchapps <Suchbegriff>

set -eu

show_help() {
  cat <<'EOF'
searchapps - search commands available in your shell / PATH (case-insensitive)

Usage:
  searchapps <query>
  searchapps --help
  searchapps --uninstall

Examples:
  searchapps ssh
  searchapps python
EOF
}

# Uninstall wird vom Installer-Wrapper/Tool unterstützt (siehe unten).
# Das Tool selbst kann nur informieren; die Logik ist hier, damit "searchapps --uninstall"
# funktioniert, wenn der Wrapper INSTALL_DIR setzt (oder config existiert).
do_uninstall() {
  # Priorität: SEARCHAPPS_DIR aus Umgebung, sonst config, sonst abbrechen
  if [ -n "${SEARCHAPPS_DIR:-}" ] && [ -d "${SEARCHAPPS_DIR:-}" ]; then
    INSTALL_DIR="$SEARCHAPPS_DIR"
  elif [ -f "$HOME/.searchapps/config" ]; then
    # shellcheck disable=SC1090
    . "$HOME/.searchapps/config"
    INSTALL_DIR="${SEARCHAPPS_DIR:-$HOME/.searchapps}"
  else
    echo "Cannot uninstall: install dir not found (missing SEARCHAPPS_DIR and config)." >&2
    exit 1
  fi

  BIN_PATH="${SEARCHAPPS_BIN:-$HOME/.local/bin/searchapps}"

  echo "Uninstalling searchapps..."
  if [ -f "$BIN_PATH" ]; then
    rm -f "$BIN_PATH"
    echo "Removed: $BIN_PATH"
  fi

  if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed: $INSTALL_DIR"
  fi

  echo "Done."
}

case "${1:-}" in
  --help|-h)
    show_help
    exit 0
    ;;
  --uninstall)
    do_uninstall
    exit 0
    ;;
  "")
    show_help() >&2
    exit 1
    ;;
esac

query="$1"

# Best effort: compgen gibt's nur in bash. Wir versuchen mehrere Strategien.
# 1) bash + compgen (beste Abdeckung)
if command -v bash >/dev/null 2>&1; then
  bash -lc 'compgen -c' 2>/dev/null | sort -u | grep -i -- "$query" && exit 0
  exit 1
fi

# 2) Fallback POSIX: PATH-Verzeichnisse durchsuchen (nur ausführbare Dateien)
# (keine Aliases/Funktionen/Builtins)
echo "$PATH" | tr ':' '\n' | while IFS= read -r d; do
  [ -d "$d" ] || continue
  # nur Dateien
  for f in "$d"/*; do
    [ -f "$f" ] || continue
    [ -x "$f" ] || continue
    basename "$f"
  done
done | sort -u | grep -i -- "$query"
