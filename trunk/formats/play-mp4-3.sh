#!/usr/local/bin/bash

FF_FORMAT="mp4"
PLAY_SIZE="_3"

FF_WIDTH=320
FF_HEIGHT=176

FF_FPS=24

FF_VBITRATE=200

FF_AB=96
FF_AC=2
FF_AR=44100


FF_PRESET1="-vpre default -vpre ipod320"
FF_PRESET2="-vpre default -vpre ipod320"


FF_PASS=2


if [[ $EVALUTE == 1 ]]
then

EVALUATION=$(echo "$EVALUATION + ($FF_WIDTH * $FF_HEIGHT * $FF_FPS * $FF_PASS * ($DURATION_S - $SS))"|bc)

else

echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"
. "$APP_DIR/formats/play-$FF_FORMAT.sh" 

fi

