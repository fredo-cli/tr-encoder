#!/usr/local/bin/bash

FF_FORMAT=flv
PLAY_SIZE="_2"

FF_WIDTH=240
FF_HEIGHT=136

FF_FPS=16

FF_VBITRATE=174

FF_AB=32
FF_AC=1
FF_AR=22050

FF_PASS=2


if [[ $EVALUTE == 1 ]]
then

EVALUATION=$(echo "$EVALUATION + ($FF_WIDTH * $FF_HEIGHT * $FF_FPS * $FF_PASS * ($DURATION_S - $SS))"|bc)

else

echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 

fi