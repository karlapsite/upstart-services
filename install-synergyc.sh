#!/bin/bash
BIN="synergyc"
TMP="/tmp/$BIN"
ETC_CONF="/etc/default/$BIN.conf"
UPSTART_CONF="/etc/init/$BIN.conf"

if [[ ! -f "$ETC_CONF" ]] ; then
cat <<'EOF' > "$TMP"
# The server address is of the form: [<hostname>][:<port>].  The hostname
# must be the address or hostname of the server.  The port overrides the
# default port, 24800.
SYNERGY_SERVER=127.0.0.1
SYNERGY_PORT=24800
EOF

    sudo mv "$TMP" "$ETC_CONF"
    sudo "${EDITOR:-vi}" "$ETC_CONF"
fi

# Check to see if the configuration already exists
if [[ -e "$UPSTART_CONF" ]] ; then
    echo "The service config is already installed at $UPSTART_CONF."
    read -p "Overwrite the service configuration? [Y/n] "
    if [[ $REPLY =~ ^N$|^n$ ]] ; then
        exit 1
    else
        sudo rm -f "$UPSTART_CONF"
    fi
fi

# Copy the service configuration to accommodate split /home and / partitions
# (No symlinks)
sudo cp "$BIN.conf $UPSTART_CONF"

# Reload upstart configuration, so it knows about the service we changed
sudo initctl reload-configuration

# Check to see if the service is already running
if P=$(pgrep "$BIN")
then
    echo "A service named $BIN is already running"
    read -p "Restart $BIN? [y/N] "
    if [[ $REPLY =~ ^Y$|^y$ ]] ; then
        sudo service $BIN stop
        # Start the new service
        sudo service $BIN start
    else
        exit 1
    fi
fi

exit 0
