#!/bin/bash

# This is a clicker that restarts the collection if it crashes over night and needs to be continued
# Requires xdotool
# mouse movements are there to keep the remmina session alive

echo "This will start clicking in 1minute."

sleep 1m

while [ 1 ]; do

xdotool mousemove 158 392
sleep 5m
xdotool mousemove 168 392
sleep 5m
xdotool mousemove 158 392
sleep 5m
xdotool mousemove 168 392
sleep 1s
echo "Click."
xdotool click 1

done
