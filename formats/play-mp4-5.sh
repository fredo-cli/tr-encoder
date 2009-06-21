#!/usr/local/bin/bash

if [[ $NEW_WIDTH -ge 640 ]]
then
PREFIX="play"
FF_FORMAT="mp4"
PLAY_SIZE="_5"

FF_WIDTH=640
FF_HEIGHT=360

FF_FPS=24

FF_VBITRATE=750

FF_AB=96
FF_AC=2
FF_AR=44100

FF_PRESET1="-vpre default -vpre ipod640"
FF_PRESET2="-vpre default -vpre ipod640"

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