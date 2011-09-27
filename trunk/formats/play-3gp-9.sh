#!/usr/local/bin/bash

PREFIX="play"
FF_FORMAT="3gp"
PLAY_SIZE="_9"

FF_WIDTH=176
FF_HEIGHT=100 ### we add 2*22 just before the video encoding
FF_HEIGHT_3G=144 ### 16/9 + 2+44-> 3g ratio
 
FF_FPS=15

FF_VBITRATE=80

FF_AB=12.2
FF_AC=1
FF_AR=8000


MPLAYER_SUB=" -subfont-text-scale 5.0 -sub-bg-color 0 -sub-bg-alpha 150 -font ${SUB_DIRECTORY}/arial.ttf -utf8 "

THREADS=1

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




