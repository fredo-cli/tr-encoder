#!/usr/local/bin/bash

if [[ $NEW_WIDTH -ge  848 ]]
then

FF_FORMAT="mp4"
PLAY_SIZE="_6"

FF_WIDTH=848
FF_HEIGHT=448

FF_FPS=24

FF_VBITRATE=1200

FF_AB=384
FF_AC=6
FF_AR=48000

FF_PRESET1="-vpre default -vpre main -level 30 -refs 2 "
FF_PRESET2="-vpre default -vpre main -level 30 -refs 2 "

echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 
fi