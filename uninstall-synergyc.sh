#!/bin/bash
BIN="synergyc"
TMP="/tmp/$BIN"
ETC_CONF="/etc/default/$BIN"
UPSTART_CONF="/etc/init/$BIN.conf"

read -p "Uninstall $BIN configuration? [y/N] "
if [[ $REPLY =~ ^Y$|^y$ ]] ; then
    # stop the service
    sudo service $BIN stop

    # clean up assocated configurations
    rm -rf "$TMP"
    sudo rm -rf "$ETC_CONF"
    sudo rm -rf "$UPSTART_CONF"

    read -p "Remove logs? [y/N] "
    if [[ $REPLY =~ ^Y$|^y$ ]] ; then
        sudo rm -rf "/var/log/upstart/$BIN.log"*
    fi

    # Reload upstart configuration, so it knows about the service we changed
    sudo initctl reload-configuration
else
    exit 1
fi

exit 0
