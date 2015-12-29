#!/bin/bash
if [[ -z $1 ]]; then 
    echo "Script requires the name of the service you're trying to install (e.g. synergyc)"
    exit 1
fi
BIN="$1"
shift

CONF="config/$BIN.sh"
LOCAL_CONF="upstart/$BIN.conf"
UPSTART_CONF="/etc/init/$BIN.conf"

# Check to see if we know about the requested service to be installed
if [[ ! -f "$LOCAL_CONF" ]]; then
    echo "Missing service configuration for '$BIN'"
    exit 1
fi

# Check if there is a local configuration file, in charge of setting up
# the service in a particular manner
if [[ -f "$CONF" ]] ; then
    # Source the sub-config scripts so they know about our environment variables
    # Hopefully they are polite, and don't trash our environment
    . "$CONF"
fi

# Check to see if the service configuration already exists
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
sudo cp "$LOCAL_CONF" "$UPSTART_CONF"

# Reload upstart configuration, so it knows about the service we changed
sudo initctl reload-configuration

# Check to see if the service is already running, and ask if the user wants to
# Restart it, or exit this script immediatly
if P=$(pgrep "$BIN")
then
    echo "A service named $BIN is already running"
    read -p "Restart $BIN? [y/N] "
    if [[ $REPLY =~ ^Y$|^y$ ]] ; then
        sudo service $BIN stop
    else
        exit 1
    fi
fi

# Start the new service
sudo service $BIN start
