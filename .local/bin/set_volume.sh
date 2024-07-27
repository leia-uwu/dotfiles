#!/bin/bash
# script to set pulseaudio volume and send a notification with the current volume

pactl set-sink-volume 0 "$1"%

volume=$(pactl list sinks | grep Volume: | head -n 1 | awk '{print $5}' | sed 's/%/''/')

if [ $volume -gt 66 ]; then 
    icon="audio-volume-high"

elif [ $volume -gt 33 ]; then
    icon="audio-volume-medium"

elif [ $volume -gt -1 ]; then
    export icon="audio-volume-low"
fi

notify-send -i $icon -t 500 -h string:synchronous:volume -h int:value:"$volume" $volume%
