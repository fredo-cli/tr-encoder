#!/usr/local/bin/bash

if [[ $NEW_WIDTH -ge  1920 ]]
then
PREFIX="play"
FF_FORMAT="mp4"
PLAY_SIZE="_8"

FF_WIDTH=1920
FF_HEIGHT=1080

FF_FPS=25

FF_VBITRATE=8000

FF_AB=384
FF_AC=6
FF_AR=48000

FF_PRESET1="-vpre default -vpre main -level 40 -refs 3 "
FF_PRESET2="-vpre default -vpre main -level 40 -refs 3 "

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
 
fi