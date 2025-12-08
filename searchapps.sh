#!/bin/sh

# Default config dir
SEARCHAPPS_DIR="${SEARCHAPPS_DIR:-$HOME/.searchapps}"
CONFIG_FILE="$SEARCHAPPS_DIR/config"

# -------------------------------------------------------------------
# Prüfen, ob ein Kommando existiert
have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# Liste installierter "Apps" aus Paketmanagern
# (dpkg/apt, snap, flatpak)
list_pkg_apps() {
    out=""

    # dpkg / apt (Debian/Ubuntu)
    if command -v dpkg-query >/dev/null 2>&1; then
        out="$out\n$(dpkg-query -W -f='${Package}\n' 2>/dev/null)"
    fi

    # snap
    if command -v snap >/dev/null 2>&1; then
        out="$out\n$(snap list 2>/dev/null | awk 'NR>1 {print $1}')"
    fi

    # flatpak
    if command -v flatpak >/dev/null 2>&1; then
        out="$out\n$(flatpak list --app --columns=application 2>/dev/null)"
    fi

    # ausgeben, sortiert
    printf "%s\n" "$out" | grep -v '^$' | sort -u
}


search_pkg_apps() {
    pattern=$1
    list_pkg_apps | grep -iF -- "$pattern"
}

# Alte (komplette) PATH-Suche (nur für --all)
list_cli_apps() {
    old_ifs=$IFS
    IFS=:
    for dir in $PATH; do
        [ -d "$dir" ] || continue
        for f in "$dir"/*; do
            [ -f "$f" ] || continue
            [ -x "$f" ] || continue
            basename "$f"
        done
    done 2>/dev/null | sort -u
    IFS=$old_ifs
}

search_cli_apps() {
    pattern=$1
    list_cli_apps | grep -iF -- "$pattern"
}

# -------------------------------------------------------------------

show_help() {
cat <<EOF
searchapps - list and search installed applications/packages

Standardquelle:
  - Debian/Ubuntu Pakete (dpkg/apt)
  - snap Pakete
  - flatpak Apps (falls vorhanden)

Usage:
  searchapps               List installed packages/apps (from dpkg, snap, flatpak)
  searchapps <pattern>     Search by package/app name (case-insensitive)
  searchapps --all <pat>   Search ALL executables in your PATH (old behaviour)
  searchapps --help        Show help
  searchapps --uninstall   Remove searchapps

Examples:
  searchapps
  searchapps code
  searchapps firefox
  searchapps --all bash
EOF
}

# -------------------------------------------------------------------

do_uninstall() {
    if [ -f "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE"
    fi

    echo "Uninstalling searchapps..."

    if [ -n "$SEARCHAPPS_BIN" ] && [ -f "$SEARCHAPPS_BIN" ]; then
        rm -f "$SEARCHAPPS_BIN"
        echo "Removed executable: $SEARCHAPPS_BIN"
    fi

    if [ -d "$SEARCHAPPS_DIR" ]; then
        rm -rf "$SEARCHAPPS_DIR"
        echo "Removed directory: $SEARCHAPPS_DIR"
    fi

    echo "Done."
}

# -------------------------------------------------------------------

case "$1" in
    --help|-h)
        show_help
        exit 0
        ;;
    --uninstall)
        do_uninstall
        exit 0
        ;;
    --all)
        shift
        if [ -n "$1" ]; then
            search_cli_apps "$1"
        else
            list_cli_apps
        fi
        exit 0
        ;;
esac

# Keine Argumente → alle Paket-/Appnamen anzeigen
if [ -z "$1" ]; then
    list_pkg_apps
    exit 0
fi

# Mit Suchbegriff
search_pkg_apps "$1"
