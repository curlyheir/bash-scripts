#!/bin/bash

echo "System Info"
echo "$LANG"
echo "$HOME"
echo "Hostname: $(hostname)"
echo  "shell : $SHELL" 
echo "Desktop : $XDG_CURRENT_DESKTOP"
echo "Kernel: $(uname -r)"
echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2)"
echo "Memory: $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
echo 'screen-height'
xrandr | awk '/ connected/{print sqrt( ($(NF-2)/10)^2 + ($NF/10)^2 )/2.54" inches"}'
echo 'screen-dimens'
xdpyinfo | awk '/dimensions/ {print $2}'

