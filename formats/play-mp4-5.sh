#!/usr/local/bin/bash

FF_FORMAT="mp4"
PLAY_SIZE="_5"

FF_WIDTH=640
FF_HEIGHT=360

FF_FPS=24

FF_VBITRATE=1200

FF_AB=96
FF_AC=2
FF_AR=44100

FF_PRESET1="-vpre fastfirstpass -vpre ipod640"
FF_PRESET2="-vpre hq -vpre ipod640"

echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 
