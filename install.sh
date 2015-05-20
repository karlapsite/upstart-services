#!/bin/bash
if [[ ! -f /etc/default/synergy ]] ; then
cat <<'EOF' > /tmp/synergy
# The server address is of the form: [<hostname>][:<port>].  The hostname
# must be the address or hostname of the server.  The port overrides the
# default port, 24800.
SYNERGY_SERVER=127.0.0.1
SYNERGY_PORT=24800
EOF

    sudo mv /tmp/synergy /etc/default/synergy
    sudo "${EDITOR:-vi}" /etc/default/synergy
fi

# Check to see if the configuration already exists
if [[ -e /etc/init/synergy.conf ]] ; then
    echo "The 'synergy.conf' service config is already installed."
    read -p "Overwrite the service configuration? [Y/n] "
    if [[ $REPLY =~ ^N$|^n$ ]] ; then
        exit 1
    else
        sudo rm -f /etc/init/synergy.conf
    fi
fi

# Create a symbolic link
sudo ln -s `pwd`/synergy.conf /etc/init/synergy.conf

# Reload upstart configuration, so it knows about the services we added
sudo initctl reload-configuration

# Check to see if synergy is already running
if P=$(pgrep synergy)
then
    echo "A service named synergy is already running"
    read -p "Restart synergy? [Y/n] "
    if [[ $REPLY =~ ^N$|^n$ ]] ; then
        exit 1
    else
        sudo service synergy stop
    fi
fi
# Start the new service
sudo service synergy start
