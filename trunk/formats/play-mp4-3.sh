#!/usr/local/bin/bash

FF_FORMAT="mp4"
PLAY_SIZE="_3"

FF_WIDTH=320
FF_HEIGHT=180

FF_FPS=24

FF_VBITRATE=270

FF_AB=96
FF_AC=2
FF_AR=44100

FF_PRESET1="-vpre fastfirstpass -vpre ipod320"
FF_PRESET2="-vpre hq -vpre ipod320"

echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 



