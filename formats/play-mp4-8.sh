#!/usr/local/bin/bash

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

FF_PASS=2
MPLAYER_SUB=" -subfont-text-scale 2 -sub-bg-color 0 -sub-bg-alpha 150 -font ${SUB_DIRECTORY}/arial.ttf -utf8 "

THREADS=1
#DEFAULT='-coder 1 -flags +loop -cmp +chroma -partitions +parti8x8+parti4x4+partp8x8+partb8x8 -me_method hex -subq 6 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 1 -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4  -flags2 +fastpskip '

#FF_PRESET1="$DEFAULT -flags2 -dct8x8 -level 40 -refs 3 "
#FF_PRESET2="$DEFAULT -flags2 -dct8x8 -level 40 -refs 3 "

FF_PRESET1=" -vpre 1080p"
FF_PRESET2=" -vpre 1080p"



	if [[ $NEW_WIDTH -ge  $FF_WIDTH ]]
		then


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

