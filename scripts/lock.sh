#!/bin/bash

activeOutput=$(xrandr | grep -E " connected (primary )?[1-9]+" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")

#if["${1}"=="pre"];then
#    sudo systemctl stop bluetooth.service
#elif["${1}"=="post"];then
#    sudo systemctl start bluetooth.service
#fi
echo $activeOutput
if [ $activeOutput == eDP1 ]
then
    ffmpeg -loglevel quiet -y -f x11grab -video_size 2560x1440 -i $DISPLAY -i ~/src/bigrick.png -filter_complex "boxblur=5:1,overlay=(main_w-overlay_w-10):(main_h-overlay_h-10)" -vframes 1  /tmp/lock_screen.png
    #ffmpeg -loglevel quiet -y -f x11grab -video_size 3840x1800 -i $DISPLAY -i ~/src/bigrick.png -filter_complex "boxblur=5:1,overlay=(main_w-overlay_w-10):(main_h-overlay_h-10)" -vframes 1  /tmp/lock_screen.png
fi
i3lock -i /tmp/lock_screen.png -c 3a3d42 -t
