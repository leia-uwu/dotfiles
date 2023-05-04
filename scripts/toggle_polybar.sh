#!/bin/bash


if [ -f /tmp/polybar_hidden ]; then
    polybar-msg cmd show;
	bspc config bottom_padding 28
	rm /tmp/polybar_hidden
else
	polybar-msg cmd hide;
	bspc config bottom_padding 0
	touch /tmp/polybar_hidden
fi

