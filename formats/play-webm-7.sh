#!/usr/local/bin/bash

PREFIX="play"
FF_FORMAT="webm"
PLAY_SIZE="_7"

FF_WIDTH=1280
FF_HEIGHT=720
FF_FPS=25
FF_VBITRATE=2000

FF_AB=384
FF_AC=6
FF_AR=48000

FF_PASS=2
THREADS=1







FF_PRESET1=" -f webm -aspect 16:9 -vcodec libvpx -g 120 \
-profile 0 \
-qmax 51 \
-qmin 10 \
-rc_buf_aggressivity 0.95 \
-rc_lookahead 16 \
-maxrate 4M \
-minrate 100k \
-level 216 -vb ${FF_VBITRATE}k -ac ${FF_AC} -ar ${FF_AR} -ab ${FF_AB}k  -acodec libvorbis -aq 4 "

FF_PRESET2=" -f webm -aspect 16:9 -vcodec libvpx -g 120 \
-profile 0 \
-qmax 51 \
-qmin 10 \
-rc_buf_aggressivity 0.95 \
-rc_lookahead 16 \
-maxrate 4M \
-minrate 100k \
-vb ${FF_VBITRATE}k -ac ${FF_AC} -ar ${FF_AR} -ab ${FF_AB}k  -acodec libvorbis -aq 4 "





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

