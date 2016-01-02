# This script is supposed to be run from ../install.sh
# Please consider running ../install.sh before running this script manually

if [[ -z "$BIN" ]]; then
    echo "BIN not defined"
    exit 1
fi

TMP="/tmp/$BIN"
ETC_CONF="/etc/default/$BIN"

if [[ ! -f "$ETC_CONF" ]]; then
cat <<EOF > "$TMP"
# The server address is of the form: [<hostname>][:<port>].  The hostname
# must be the address or hostname of the server.  The port overrides the
# default port, 24800.
SYNERGY_SERVER=127.0.0.1
SYNERGY_PORT=24800
EOF
    sudo mv "$TMP" "$ETC_CONF"
    sudo "${EDITOR:-vi}" "$ETC_CONF"
fi
