#!/bin/sh

# Main script for the 'searchapps' CLI tool

SEARCHAPPS_DIR="${SEARCHAPPS_DIR:-$HOME/.searchapps}"
CONFIG_FILE="$SEARCHAPPS_DIR/config"

# --- Desktop-Apps aus .desktop-Dateien lesen ---

list_desktop_apps() {
    # Format der Ausgabe: EXEC<TAB>NAME
    for dir in /usr/share/applications "$HOME/.local/share/applications"; do
        [ -d "$dir" ] || continue
        # alle .desktop-Dateien
        for f in "$dir"/*.desktop; do
            [ -f "$f" ] || continue

            # Name= (erste Zeile)
            name=$(grep -m1 '^Name=' "$f" 2>/dev/null | sed 's/^Name=//')
            # Exec= (erste Zeile)
            exec=$(grep -m1 '^Exec=' "$f" 2>/dev/null | sed 's/^Exec=//')

            # Exec auf das eigentliche Kommando kürzen (erstes Wort, ohne %U etc.)
            # Beispiele: "code --unity" -> "code", "discord %U" -> "discord"
            exec=$(printf '%s\n' "$exec" | awk '{print $1}')

            [ -n "$exec" ] || continue
            [ -n "$name" ] || name="$exec"

            # Nur einmal pro (exec,name)-Kombi
            printf '%s\t%s\n' "$exec" "$name"
        done
    done | sort -u
}

print_desktop_apps_pretty() {
    # einfache Ausgabe: "exec - Name"
    list_desktop_apps | while IFS="$(printf '\t')" read -r exec name; do
        printf '%s - %s\n' "$exec" "$name"
    done
}

search_desktop_apps() {
    pattern=$1
    list_desktop_apps | grep -iF -- "$pattern" | while IFS="$(printf '\t')" read -r exec name; do
        printf '%s - %s\n' "$exec" "$name"
    done
}

# --- Alte Logik: alle PATH-Executables (für --all) ---

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

show_help() {
    cat <<EOF
searchapps - search installed applications on your system

Usage:
  searchapps                   List desktop applications (.desktop files)
  searchapps <pattern>         Search desktop apps by name or exec (case-insensitive)
  searchapps --all <pattern>   Search all executable commands in your PATH (old behavior)
  searchapps --help            Show this help message
  searchapps --uninstall       Remove searchapps from this system

Examples:
  searchapps
  searchapps code
  searchapps discord
  searchapps --all grep
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

# --- Argument-Handling ---

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

if [ "$1" = "--uninstall" ]; then
    do_uninstall
    exit 0
fi

if [ "$1" = "--all" ]; then
    # alte CLI-Variante verwenden
    shift
    if [ -z "$1" ]; then
        # keine Suche → alles ausgeben
        list_cli_apps
    else
        search_cli_apps "$1"
    fi
    exit 0
fi

# Kein Argument → alle Desktop-Apps anzeigen
if [ -z "$1" ]; then
    print_desktop_apps_pretty
    exit 0
fi

# Sonst: Desktop-Apps nach Pattern durchsuchen
search_desktop_apps "$1"
