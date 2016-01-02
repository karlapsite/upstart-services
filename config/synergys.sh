# This script is supposed to be run from ../install.sh
# Please consider running ../install.sh before running this script manually

# Leave this check in because we should error if BIN wasn't set to synergys previously
if [[ -z "$BIN" ]]; then
    echo "BIN not defined"
    exit 1
fi

# Borrow the configuration for synergyc, but with a different BIN name (synergys)
borrow "synergyc.sh"

# Create a monitor configuration
TMP="/tmp/$BIN-monitor.conf"
ETC_CONF="/etc/default/$BIN-monitor.conf"
HOSTNAME="$(hostname)"

if [[ ! -f "$ETC_CONF" ]]; then
cat <<EOF > "$TMP"
# Example Montior Setup
#   []
# [][]

# section: screens 
#   Where you set the hostnames of the computers going to be used.
# section: links
#   What side the mouse will leave the screen of one computer to reach the
#   desktop of the other. myserver is set to the left of myclient.

section: screens
    $HOSTNAME:
    myclient:
end

section: links
    $HOSTNAME:
        left(50,100) = myclient
    myclient:
        right = $HOSTNAME(50,100)
end
EOF
    sudo mv "$TMP" "$ETC_CONF"
    sudo "${EDITOR:-vi}" "$ETC_CONF"
fi
