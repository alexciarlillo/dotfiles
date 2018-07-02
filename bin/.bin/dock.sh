#!/bin/bash

DOCKED=$(cat /sys/devices/platform/dock.0/docked)
case "$DOCKED" in
        "0")
        #undocked event
        /home/ciarlill/.bin/undocked
        ;;
        "1")
        #docked event
        /home/ciarlill/.bin/docked
        ;;
esac
exit 0


