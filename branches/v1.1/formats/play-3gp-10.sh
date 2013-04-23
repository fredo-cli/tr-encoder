#!/usr/local/bin/bash

PREFIX="play"
FF_FORMAT="3gp"
PLAY_SIZE="_10"

FF_WIDTH=176
FF_HEIGHT=100 ### we add 2*22 just before the video encoding
FF_HEIGHT_3G=144 ### 16/9 + 2+44-> 3g ratio

FF_FPS=15

FF_VBITRATE=80

FF_AB=32
FF_AC=1
FF_AR=16000

MPLAYER_SUB=" -subfont-text-scale 5.0 -sub-bg-color 0 -sub-bg-alpha 150 -font ${SUB_DIRECTORY}/arial.ttf -utf8 "

THREADS=1
DEFAULT='-coder 1 -flags +loop -cmp +chroma -partitions +parti8x8+parti4x4+partp8x8+partb8x8 -me_method hex -subq 6 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 1 -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4  -flags2 +fastpskip '

FF_PRESET1="$DEFAULT -coder 1 -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -me_method hex -subq 6 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 1"
FF_PRESET2="$DEFAULT -coder 1 -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -me_method hex -subq 6 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 1"


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

. "$APP_DIR/formats/$PREFIX-${FF_FORMAT}p.sh" 

fi






