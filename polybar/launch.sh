#!/usr/bin/env sh

killall -q polybar

while pgrep -x polybar >/dev/null; do sleep 1; done

# launch on each monitor
xrandr --query | grep "[[:space:]]connected" | cut -d ' ' -f 1 | while read -r line ; do
    MONITOR="$line" polybar top &
    echo "Polybar started on $line"
done

