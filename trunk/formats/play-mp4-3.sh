#!/usr/bin/bash		

echo -e "\\n${BLUE}$(box "format: play-mp4-3")${NC}"

FF_WIDTH=320
FF_HEIGHT=180

FF_VBITRATE=270

FF_PRESET1="-vpre fastfirstpass -vpre ipod320"
FF_PRESET2="-vpre hq -vpre ipod320"

PLAY_SIZE="_3"

. "$APP_DIR/formats/play-mp4.sh" 