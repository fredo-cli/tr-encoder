#!/usr/local/bin/bash

FF_FORMAT="wmv"
PLAY_SIZE="_4"

FF_WIDTH=400
FF_HEIGHT=226

FF_FPS=24

FF_VBITRATE=450

FF_AB=96
FF_AC=2
FF_AR=44100

echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 