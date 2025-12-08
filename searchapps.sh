#!/bin/sh

# === SEARCHAPPS: apt/snap/flatpak + optional --all ===

SEARCHAPPS_DIR="${SEARCHAPPS_DIR:-$HOME/.searchapps}"
CONFIG_FILE="$SEARCHAPPS_DIR/config"

# ---------------------------------------------------------
# Quelle 1: APT/dpkg
get_apt_apps() {
    if command -v dpkg >/dev/null 2>&1; then
        dpkg --get-selections 2>/dev/null | awk '{print $1}'
    fi
}

# Quelle 2: SNAP
get_snap_apps() {
    if command -v snap >/dev/null 2>&1; then
        snap list 2>/dev/null | awk 'NR>1 {print $1}'
    fi
}

# Quelle 3: Flatpak
get_flatpak_apps() {
    if command -v flatpak >/dev/null 2>&1; then
        flatpak list --columns=application 2>/dev/null
    fi
}

# Alle Executables im PATH (für --all)
get_path_apps() {
    old_ifs=$IFS
    IFS=:
    for dir in $PATH; do
        [ -d "$dir" ] || continue
        for f in "$dir"/*; do
            [ -f "$f" ] || continue
            [ -x "$f" ] || continue
            basename "$f"
        done
    done 2>/dev/null
    IFS=$old_ifs
}

# ---------------------------------------------------------
# Uninstall
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

    exit 0
}

# ---------------------------------------------------------
# Argument Handling: Optionen zuerst

case "$1" in
    --uninstall)
        do_uninstall
        ;;
    --help|-h)
        cat <<EOF
searchapps - list/search installed apt/snap/flatpak applications

Usage:
  searchapps               # list all installed apps (apt/snap/flatpak)
  searchapps <pattern>     # search installed apps
  searchapps --all <pat>   # search ALL executables in your PATH
  searchapps --help
  searchapps --uninstall
EOF
        exit 0
        ;;
    --all)
        shift
        all_path_apps=$(get_path_apps | sort -u)
        if [ -z "$1" ]; then
            printf "%s\n" "$all_path_apps"
        else
            printf "%s\n" "$all_path_apps" | grep -iF "$1"
        fi
        exit 0
        ;;
esac

# ---------------------------------------------------------
# DATEN AUS PAKETMANAGERN SAMMELN

all_apps=$(
    get_apt_apps
    get_snap_apps
    get_flatpak_apps
)

# Kein Argument → komplette Liste
if [ -z "$1" ]; then
    printf "%s\n" "$all_apps" | sort -u
    exit 0
fi

# Mit Argument → Suche in Paket/App-Namen
pattern=$1
printf "%s\n" "$all_apps" | sort -u | grep -iF "$pattern"
