#!/bin/bash

CURRENT_OUTPUT=$(pactl list | grep "Active Port" | awk '{print $3}')


if [ "$CURRENT_OUTPUT" = "analog-output-headphones" ]; then
    pactl set-sink-port alsa_output.pci-0000_00_1b.0.analog-stereo analog-output-lineout
else
    pactl set-sink-port alsa_output.pci-0000_00_1b.0.analog-stereo analog-output-headphones
fi

notify-send -t 900 -h string:synchronous:audio-output $(pactl list | grep "Active Port" | awk '{print $3}')
