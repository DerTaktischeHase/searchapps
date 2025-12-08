#!/bin/sh

set -e

REPO_USER="DerTaktischeHase"
REPO_NAME="searchapps"
REPO_RAW_BASE="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/main"

DEFAULT_INSTALL_DIR="$HOME/.searchapps"
DEFAULT_BIN_DIR="$HOME/.local/bin"

echo "=== searchapps installer ==="
echo

# Installationsverzeichnis abfragen
printf "Install directory for searchapps.sh [%s]: " "$DEFAULT_INSTALL_DIR"
read -r INSTALL_DIR
[ -n "$INSTALL_DIR" ] || INSTALL_DIR="$DEFAULT_INSTALL_DIR"

# Bin-Verzeichnis (für das 'searchapps' Kommando) abfragen
printf "Directory for the 'searchapps' executable (must be in PATH) [%s]: " "$DEFAULT_BIN_DIR"
read -r BIN_DIR
[ -n "$BIN_DIR" ] || BIN_DIR="$DEFAULT_BIN_DIR"

BIN_PATH="$BIN_DIR/searchapps"

echo
echo "-> Using install dir: $INSTALL_DIR"
echo "-> Using bin dir:     $BIN_DIR"
echo "-> Executable path:   $BIN_PATH"
echo

# Verzeichnisse anlegen
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# Hauptscript herunterladen
echo "Downloading searchapps.sh..."
curl -fsSL "$REPO_RAW_BASE/searchapps.sh" -o "$INSTALL_DIR/searchapps.sh"
chmod +x "$INSTALL_DIR/searchapps.sh"

# Wrapper im Bin-Verzeichnis erstellen
echo "Creating wrapper at $BIN_PATH..."
cat > "$BIN_PATH" <<EOF
#!/bin/sh
exec "$INSTALL_DIR/searchapps.sh" "\$@"
EOF

chmod +x "$BIN_PATH"

# Config-Datei schreiben
CONFIG_FILE="$INSTALL_DIR/config"
echo "Writing config to $CONFIG_FILE..."
cat > "$CONFIG_FILE" <<EOF
SEARCHAPPS_DIR="$INSTALL_DIR"
SEARCHAPPS_BIN="$BIN_PATH"
EOF

# Prüfen, ob BIN_DIR im PATH ist
case ":$PATH:" in
    *":$BIN_DIR:"*)
        IN_PATH=1
        ;;
    *)
        IN_PATH=0
        ;;
esac

add_to_rc() {
    rcfile=$1
    line=$2

    if [ ! -f "$rcfile" ]; then
        touch "$rcfile"
    fi

    if ! grep -F "$line" "$rcfile" >/dev/null 2>&1; then
        echo "$line" >> "$rcfile"
        echo "  Added to $rcfile: $line"
    else
        echo "  PATH entry already present in $rcfile"
    fi
}

if [ "$IN_PATH" -eq 0 ]; then
    echo
    echo "NOTE: $BIN_DIR is not in your PATH. Trying to add it automatically..."

    SHELL_BASENAME=$(basename "${SHELL:-sh}")

    case "$SHELL_BASENAME" in
        bash)
            add_to_rc "$HOME/.bashrc" "export PATH=\"$BIN_DIR:\$PATH\""
            ;;
        zsh)
            add_to_rc "$HOME/.zshrc" "export PATH=\"$BIN_DIR:\$PATH\""
            ;;
        fish)
            FISH_RC="$HOME/.config/fish/config.fish"
            mkdir -p "$(dirname "$FISH_RC")"
            if [ ! -f "$FISH_RC" ]; then
                touch "$FISH_RC"
            fi
            if ! grep -F "set -gx PATH \"$BIN_DIR\" \$PATH" "$FISH_RC" >/dev/null 2>&1; then
                echo "set -gx PATH \"$BIN_DIR\" \$PATH" >> "$FISH_RC"
                echo "  Added to $FISH_RC: set -gx PATH \"$BIN_DIR\" \$PATH"
            else
                echo "  PATH entry already present in $FISH_RC"
            fi
            ;;
        *)
            echo "  Unknown shell: $SHELL_BASENAME"
            echo "  Please add $BIN_DIR to your PATH manually."
            ;;
    esac
else
    echo "Good: $BIN_DIR is already in PATH."
fi

echo
echo "Installation complete."
echo "You can now run: searchapps"
echo "For help:        searchapps --help"
echo "To uninstall:    searchapps --uninstall"
echo
echo "If the command is not found immediately, open a new terminal or 'source' your shell config."
