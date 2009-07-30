#!/usr/local/bin/bash

PREFIX="play"
FF_FORMAT="3gp"
PLAY_SIZE="_9"

FF_WIDTH=176
FF_HEIGHT=100 # +44

FF_FPS=15

FF_VBITRATE=80

FF_AB=12.2
FF_AC=1
FF_AR=8000

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

. "$APP_DIR/formats/$PREFIX-${FF_FORMAT}.sh" 

fi




