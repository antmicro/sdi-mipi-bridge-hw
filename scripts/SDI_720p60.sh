#!/bin/sh

set -e

echo "Loading FPGA bitstream..."
echo "sdi_bridge/sdi_bridge_720p60.bit" | sudo tee /sys/class/fpga_manager/fpga0/load

export DISPLAY=$(sudo strings /proc/$(pgrep -u $USER gnome-session-b)/environ | grep DISPLAY | cut -d'=' -f 2)

echo "Stream start"
gst-launch-1.0 v4l2src device=/dev/video0 ! 'video/x-raw,width=1280,height=720' ! xvimagesink
