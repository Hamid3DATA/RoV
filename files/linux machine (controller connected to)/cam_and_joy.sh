#!/bin/bash

gnome-terminal -- gst-launch-1.0 -v udpsrc port=3334 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! rtpjpegdepay ! jpegdec ! videoflip method=rotate-180 ! videoconvert ! autovideosink
sleep 0.5
gnome-terminal -- python3 gameCnt.py
