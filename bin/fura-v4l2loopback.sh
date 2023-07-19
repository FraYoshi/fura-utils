#!/bin/bash -
source ~/.config/furayoshi/config.sh

echo "NOTICE: run with sudo -E to preserve configuration varibles"

modprobe v4l2loopback exclusive_caps=1 $card_label="$CARDLABEL" max_widht=$V4L2WIDTH max_height=$V4L2HEIGHT video_nr=$V4L2NUMBER \
    && echo -e "Loopback of name $CARDLABEL with max_width $V4L2WIDTH and  max_height $V4L2HEIGHT has been created as Video number $V4L2NUMBER." \
    && v4l2-ctl -vwidth=$V4L2WIDTH,height=$V4L2HEIGHT,pixelformat=$V4L2PIXELFORMAT \
    && echo -e "V4L2 interface set to the pixel format $V4L2PIXELFORMAT and width $V4L2WIDTH height $V4L2HEIGHT." \
    && echo -e "You might now start feeding the interface with something like ffmpeg -i /dev/video0 -f v4l2 -codec:v rawvideo -pix_fmt yuv420p /dev/video$V4L2NUMBER" \
	    && echo -e "disable everything with rmmod v4l2loopback"
