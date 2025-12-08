#!/bin/sh

# Main script for the 'searchapps' CLI tool

SEARCHAPPS_DIR="${SEARCHAPPS_DIR:-$HOME/.searchapps}"
CONFIG_FILE="$SEARCHAPPS_DIR/config"

# Alle Apps im PATH auflisten (nur ausführbare Dateien, keine Dirs)
list_apps() {
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

show_help() {
    cat <<EOF
searchapps - list and search executable commands available in your PATH

Usage:
  searchapps                List all commands in your PATH
  searchapps <pattern>      Search commands (case-insensitive substring)
  searchapps --help         Show this help message
  searchapps --uninstall    Remove searchapps from this system

Examples:
  searchapps
  searchapps code
  searchapps disc
EOF
}

do_uninstall() {
    # Konfig lesen, falls vorhanden
    if [ -f "$CONFIG_FILE" ]; then
        # shellcheck disable=SC1090
        . "$CONFIG_FILE"
    fi

    echo "Uninstalling searchapps..."

    # Wrapper/Executable entfernen
    if [ -n "$SEARCHAPPS_BIN" ] && [ -f "$SEARCHAPPS_BIN" ]; then
        echo "  Removing executable: $SEARCHAPPS_BIN"
        rm -f "$SEARCHAPPS_BIN"
    fi

    # Hauptordner entfernen
    if [ -d "$SEARCHAPPS_DIR" ]; then
        echo "  Removing directory: $SEARCHAPPS_DIR"
        rm -rf "$SEARCHAPPS_DIR"
    fi

    echo "searchapps has been uninstalled."
}

# --- Main argument handling ---

case "$1" in
    "" )
        # Alle Apps listen
        list_apps
        ;;
    --help|-h)
        show_help
        ;;
    --uninstall)
        do_uninstall
        ;;
    *)
        # Suche nach Teilstring (case-insensitive, literal)
        pattern=$1
        list_apps | grep -iF -- "$pattern"
        ;;
esac
