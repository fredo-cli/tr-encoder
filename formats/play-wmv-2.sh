#!/usr/local/bin/bash
PREFIX="play"
FF_FORMAT="wmv"
PLAY_SIZE="_2"

FF_WIDTH=240
FF_HEIGHT=136

FF_FPS=16

FF_VBITRATE=174

FF_AB=32
FF_AC=1
FF_AR=22050

FF_PASS=2


if [[ $EVALUTE == 1 && $EVALUATION == 0 ]]
then

### evalute only once or encode

evaluation_ini

### check the evolution of the encoding

elif [[ $EVALUTE == 1 && $EVALUATION -gt 0 ]]
then

evaluation_check

else

### encode the video

. "$APP_DIR/formats/$PREFIX-$FF_FORMAT.sh" 

fi