#!/usr/local/bin/bash

if [[ $NEW_WIDTH -ge  1280 ]]
then

FF_FORMAT="mp4"
PLAY_SIZE="_7"

FF_WIDTH=1280
FF_HEIGHT=720

FF_FPS=25

FF_VBITRATE=2000

FF_AB=384
FF_AC=6
FF_AR=48000

FF_PRESET1="-vpre default -vpre main -level 31 -refs 3 "
FF_PRESET2="-vpre default -vpre main -level 31 -refs 3 "

echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 
fi