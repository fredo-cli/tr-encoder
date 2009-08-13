#!/usr/local/bin/bash

PREFIX="play"
FF_FORMAT="mp4"
PLAY_SIZE="_4"

FF_WIDTH=480
FF_HEIGHT=272
FF_FPS=24
FF_VBITRATE=450

FF_AB=128
FF_AC=2
FF_AR=44100

FF_PASS=2
MPLAYER_SUB=" -subfont-text-scale 2 -sub-bg-color 0 -sub-bg-alpha 150 -font ${SUB_DIRECTORY}/arial.ttf -utf8 "

THREADS=1	   
FF_PRESET1="-vpre default -vpre main -refs 2 -bf 0"
FF_PRESET2="-vpre default -vpre main -refs 2 -bf 0"





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