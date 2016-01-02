# This script is supposed to be run from ../uninstall.sh
# Please consider running ../uninstall.sh before running this script manually

if [[ -z "$BIN" ]]; then
    echo "BIN not defined"
    exit 1
fi

# Borrow the cleanup for synergyc, but with a different BIN name (synergys)
borrow "synergyc.sh"

sudo rm -rf "/etc/default/$BIN-monitor.conf"
