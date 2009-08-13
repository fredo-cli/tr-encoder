#!/usr/local/bin/bash

PREFIX="play"
FF_FORMAT="flv"
PLAY_SIZE="_1"

FF_WIDTH=160
FF_HEIGHT=90
FF_FPS=12
FF_VBITRATE=86

FF_AB=16
FF_AC=1
FF_AR=11025

FF_PASS=2
MPLAYER_SUB=" -subfont-text-scale 5.0 -sub-bg-color 0 -sub-bg-alpha 150 -font /usr/share/fonts/truetype/msttcorefonts/arial.ttf -utf8 "





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