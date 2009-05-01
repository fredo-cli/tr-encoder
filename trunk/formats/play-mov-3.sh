#!/usr/local/bin/bash

FF_FORMAT="mov"
PLAY_SIZE="_3"

FF_WIDTH=320
FF_HEIGHT=180

FF_FPS=24

FF_VBITRATE=270

FF_AB=96
FF_AC=2
FF_AR=44100




echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 


