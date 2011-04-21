#!/usr/local/bin/bash

PREFIX="play"
FF_FORMAT="webm"
PLAY_SIZE="_4"

FF_WIDTH=480
FF_HEIGHT=272
FF_FPS=24
FF_VBITRATE=450

FF_AB=128
FF_AC=2
FF_AR=44100

FF_PASS=2
THREADS=1

FF_PRESET1=" -f webm -aspect 16:9 -vcodec libvpx -g 120 -level 216 -profile 0 -qmax 42 -qmin 10 -rc_buf_aggressivity 0.95 -vb ${FF_VBITRATE}k -ac ${FF_AC} -ar ${FF_AR} -ab ${FF_AB}k  -acodec libvorbis -aq 4 "
FF_PRESET2=" -f webm -aspect 16:9 -vcodec libvpx -g 120 -level 216 -profile 0 -qmax 42 -qmin 10 -rc_buf_aggressivity 0.95 -vb ${FF_VBITRATE}k -ac ${FF_AC} -ar ${FF_AR} -ab ${FF_AB}k  -acodec libvorbis -aq 4 "




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

