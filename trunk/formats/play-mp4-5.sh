#!/usr/bin/bash		


echo -e "\\n${BLUE}$(box "format: play-mp4-5")${NC}"

FF_WIDTH=640
FF_HEIGHT=360

FF_VBITRATE=1200

FF_PRESET1="-vpre fastfirstpass -vpre ipod640"
FF_PRESET2="-vpre hq -vpre ipod640"

PLAY_SIZE="_5"

. "$APP_DIR/formats/play-mp4.sh" 