#!/bin/bash

# Used to borrow cleanup scripts with identical configurations, but
# different BIN's
function borrow() {
if [[ -z $1 ]]; then
    echo "'borrow' requires a filename"
    exit 1
fi
if [[ ! -f "cleanup/$1" ]]; then
    echo "cleanup/$1 missing!"
    exit 1
fi

. "cleanup/$1"
}

# Start Script
if [[ -z $1 ]]; then 
    echo "Script requires the name of the service you're trying to install (e.g. synergyc)"
    exit 1
fi
BIN="$1"
shift

LOCAL_CONF="upstart/$BIN.conf"
UPSTART_CONF="/etc/init/$BIN.conf"
UNINST="cleanup/$BIN.sh"

# Check to see if we know about the requested service to be installed
if [[ ! -f "$LOCAL_CONF" ]]; then
    echo "Missing service configuration for '$BIN'"
    exit 1
fi

# Prompt if the user REALLY wants to uninstall
read -p "Uninstall $BIN configuration? [Y/n] "
if [[ $REPLY =~ ^N$|^n$ ]] ; then
    exit 1
fi

# stop the service
sudo service $BIN stop

# clean up assocated configurations
sudo rm -rf "$UPSTART_CONF"

# Check if there is a local uninstaller script, in charge of cleaning up
# the service in a particular manner
if [[ -f "$UNINST" ]] ; then
    # Source the sub-config scripts so they know about our environment 
    # variables. Hopefully they are polite, and don't trash our environment
    . "$UNINST"
fi

read -p "Remove logs? [y/N] "
if [[ $REPLY =~ ^Y$|^y$ ]] ; then
    sudo rm -rf "/var/log/upstart/$BIN.log"*
fi

# Reload upstart configuration, so it knows about the service we changed
sudo initctl reload-configuration
