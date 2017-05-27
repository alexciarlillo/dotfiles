#!/usr/bin/env sh

killall -q polybar

while pgrep -x polybar >/dev/null; do sleep 1; done

# launch on each monitor
xrandr --query | grep "[[:space:]]connected" | while read -r line ; do
    monitor=$( echo "$line" | cut -d' ' -f1 )
    MONITOR="$monitor" polybar top &
    echo "Polybar started on $line with width $width"
done

