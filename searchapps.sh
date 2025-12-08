#!/bin/sh

# Default config dir
SEARCHAPPS_DIR="${SEARCHAPPS_DIR:-$HOME/.searchapps}"
CONFIG_FILE="$SEARCHAPPS_DIR/config"

# -------------------------------------------------------------------
# Sammle alle App-Befehle aus .desktop Dateien
list_desktop_execs() {
    for dir in /usr/share/applications "$HOME/.local/share/applications"; do
        [ -d "$dir" ] || continue

        for f in "$dir"/*.desktop; do
            [ -f "$f" ] || continue

            # Exec= line holen
            exec=$(grep -m1 '^Exec=' "$f" 2>/dev/null | sed 's/^Exec=//')

            # Erstes Wort (Befehl + evtl. Pfad)
            exec=$(printf '%s\n' "$exec" | awk '{print $1}')

            [ -n "$exec" ] || continue

            # Wenn Pfad enthalten → nur basename nehmen
            exec=$(basename "$exec")

            [ -n "$exec" ] || continue

            printf '%s\n' "$exec"
        done
    done | sort -u
}

# Suche innerhalb der Desktop-Befehle
search_desktop_execs() {
    pattern=$1
    list_desktop_execs | grep -iF -- "$pattern"
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
searchapps - list and search installed applications

Usage:
  searchapps               List application commands (from .desktop files)
  searchapps <pattern>     Search apps by command (case-insensitive)
  searchapps --all <pat>   Search ALL executables in your PATH
  searchapps --help        Show help
  searchapps --uninstall   Remove searchapps

Examples:
  searchapps
  searchapps code
  searchapps fire
  searchapps --all grep
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
