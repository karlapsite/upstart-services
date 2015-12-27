#!/bin/bash
SYNERGYC='/etc/init/synergyc.conf'

if [[ ! -f /etc/default/synergy ]] ; then
cat <<'EOF' > /tmp/synergyc
# The server address is of the form: [<hostname>][:<port>].  The hostname
# must be the address or hostname of the server.  The port overrides the
# default port, 24800.
SYNERGY_SERVER=127.0.0.1
SYNERGY_PORT=24800
EOF

    sudo mv /tmp/synergyc/etc/default/synergyc
    sudo "${EDITOR:-vi}" /etc/default/synergyc
fi

# Check to see if the configuration already exists
if [[ -e "$SYNERGYC" ]] ; then
    echo "The 'synergy.conf' service config is already installed."
    read -p "Overwrite the service configuration? [Y/n] "
    if [[ $REPLY =~ ^N$|^n$ ]] ; then
        exit 1
    else
        sudo rm -f "$SYNERGYC"
    fi
fi

# Create a symbolic link
# sudo ln -s `pwd`/synergy.conf /etc/init/synergy.conf
# Actually... just copy it because that's how I set up other PC's with split /home and / partitions
sudo cp synergyc.conf            "$SYNERGYC"

# Reload upstart configuration, so it knows about the services we added
sudo initctl reload-configuration

# Check to see if synergy is already running
if P=$(pgrep synergyc)
then
    echo "A service named synergyc is already running"
    read -p "Restart synergy? [y/N] "
    if [[ $REPLY =~ ^Y$|^y$ ]] ; then
        sudo service synergyc stop
        # Start the new service
        sudo service synergyc start
    else
        exit 1
    fi
fi

exit 0
