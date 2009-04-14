#!/usr/local/bin/bash

FF_FORMAT=flv
PLAY_SIZE="_1"

FF_WIDTH=160
FF_HEIGHT=90

FF_FPS=12

FF_VBITRATE=86

FF_AB=16
FF_AC=1
FF_AR=11025

echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 