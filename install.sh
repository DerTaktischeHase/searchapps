#!/bin/sh
set -e

REPO_USER="DerTaktischeHase"
REPO_NAME="searchapps"
REPO_RAW_BASE="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/main"

DEFAULT_INSTALL_DIR="$HOME/.searchapps"
DEFAULT_BIN_DIR="$HOME/.local/bin"

echo "=== searchapps installer ==="
echo

if [ -t 0 ]; then
  printf "Install directory for searchapps.sh [%s]: " "$DEFAULT_INSTALL_DIR"
  read -r INSTALL_DIR
  [ -n "$INSTALL_DIR" ] || INSTALL_DIR="$DEFAULT_INSTALL_DIR"

  printf "Directory for the 'searchapps' executable (must be in PATH) [%s]: " "$DEFAULT_BIN_DIR"
  read -r BIN_DIR
  [ -n "$BIN_DIR" ] || BIN_DIR="$DEFAULT_BIN_DIR"
else
  INSTALL_DIR="$DEFAULT_INSTALL_DIR"
  BIN_DIR="$DEFAULT_BIN_DIR"
  echo "Non-interactive mode detected (probably curl | sh)."
  echo "Using defaults:"
  echo "  Install dir: $INSTALL_DIR"
  echo "  Bin dir:     $BIN_DIR"
fi

BIN_PATH="$BIN_DIR/searchapps"

echo
echo "-> Using install dir: $INSTALL_DIR"
echo "-> Using bin dir:     $BIN_DIR"
echo "-> Executable path:   $BIN_PATH"
echo

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# Preconditions
if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required. Install it first (e.g. sudo apt install curl)." >&2
  exit 1
fi

echo "Downloading searchapps.sh..."
curl -fsSL "$REPO_RAW_BASE/searchapps.sh" -o "$INSTALL_DIR/searchapps.sh"
chmod +x "$INSTALL_DIR/searchapps.sh"

echo "Creating wrapper at $BIN_PATH..."
cat > "$BIN_PATH" <<EOF
#!/bin/sh
# Wrapper for searchapps
export SEARCHAPPS_DIR="$INSTALL_DIR"
export SEARCHAPPS_BIN="$BIN_PATH"
exec "$INSTALL_DIR/searchapps.sh" "\$@"
EOF
chmod +x "$BIN_PATH"

CONFIG_FILE="$INSTALL_DIR/config"
echo "Writing config to $CONFIG_FILE..."
cat > "$CONFIG_FILE" <<EOF
SEARCHAPPS_DIR="$INSTALL_DIR"
SEARCHAPPS_BIN="$BIN_PATH"
EOF

case ":$PATH:" in
  *":$BIN_DIR:"*) IN_PATH=1 ;;
  *) IN_PATH=0 ;;
esac

add_to_rc() {
  rcfile=$1
  line=$2

  [ -f "$rcfile" ] || : > "$rcfile"

  if ! grep -F "$line" "$rcfile" >/dev/null 2>&1; then
    printf "\n%s\n" "$line" >> "$rcfile"
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
    bash) add_to_rc "$HOME/.bashrc" "export PATH=\"$BIN_DIR:\$PATH\"" ;;
    zsh)  add_to_rc "$HOME/.zshrc"  "export PATH=\"$BIN_DIR:\$PATH\"" ;;
    fish)
      FISH_RC="$HOME/.config/fish/config.fish"
      mkdir -p "$(dirname "$FISH_RC")"
      [ -f "$FISH_RC" ] || : > "$FISH_RC"
      if ! grep -F "set -gx PATH \"$BIN_DIR\" \$PATH" "$FISH_RC" >/dev/null 2>&1; then
        printf "\nset -gx PATH \"%s\" \$PATH\n" "$BIN_DIR" >> "$FISH_RC"
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
echo "You can now run: searchapps <query>"
echo "Help:           searchapps --help"
echo "Uninstall:      searchapps --uninstall"
echo
echo "If the command is not found immediately, open a new terminal or 'source' your shell config."
