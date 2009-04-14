#!/usr/local/bin/bash

FF_FORMAT="wmv"
PLAY_SIZE="_2"

FF_WIDTH=240
FF_HEIGHT=136

FF_FPS=16

FF_VBITRATE=174

FF_AB=32
FF_AC=1
FF_AR=22050

echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 