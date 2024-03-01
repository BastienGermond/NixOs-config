#!/usr/bin/env bash

# Terminate already running bar instances
pkill polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Find the right thermal zone number
for thermal in /sys/class/thermal/thermal_zone*; do
    if [ "$(cat "$thermal/type")" = 'x86_pkg_temp' ]; then
        CPU_THERMAL_ZONE=$(echo $thermal | sed 's/\/sys\/class\/thermal\/thermal_zone//')
        break;
    fi
done

if [ -z "$CPU_THERMAL_ZONE" ]; then
    echo "Coudn't find cpu thermal zone"
    exit 1
fi

export CPU_THERMAL_ZONE=$CPU_THERMAL_ZONE

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar default &
  done
else
    # Launch Polybar, using default config location ~/.config/polybar/config
    polybar default &
fi

echo "Polybar launched!"
