#!/usr/local/bin/bash

FF_FORMAT="wmv"
PLAY_SIZE="_1"

FF_WIDTH=160
FF_HEIGHT=90

FF_FPS=12

FF_VBITRATE=86

FF_AB=32
FF_AC=1
FF_AR=11025

FF_PASS=2


if [[ $EVALUTE == 1 ]]
then

EVALUATION=$(echo "$EVALUATION + ($FF_WIDTH * $FF_HEIGHT * $FF_FPS * $FF_PASS * ($DURATION_S - $SS))"|bc)

else

echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 

fi