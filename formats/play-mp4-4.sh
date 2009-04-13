#!/usr/bin/bash		

echo -e "\\n${BLUE}$(box "format: play-mp4-3")${NC}"

FF_WIDTH=480
FF_HEIGHT=272

FF_VBITRATE=650



 FF_PRESET1=" -flags +loop+mv4 -cmp 256 \
	   -partitions +parti4x4+parti8x8+partp4x4+partp8x8+partb8x8 \
	   -me_method hex -subq 7 -trellis 1 -refs 5 -bf 0 \
	   -flags2 +mixed_refs -coder 0 -me_range 16 \
           -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -qmin 10\
	   -qmax 51 -qdiff 4"


 FF_PRESET2=" -flags +loop+mv4 -cmp 256 \
	   -partitions +parti4x4+parti8x8+partp4x4+partp8x8+partb8x8 \
	   -me_method hex -subq 7 -trellis 1 -refs 5 -bf 0 \
	   -flags2 +mixed_refs -coder 0 -me_range 16 \
           -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -qmin 10\
	   -qmax 51 -qdiff 4"
	   
FF_PRESET1="-vpre default -vpre main -refs 2 -bf 0"
FF_PRESET2="-vpre default -vpre main -refs 2 -bf 0"

PLAY_SIZE="_4"

. "$APP_DIR/formats/play-mp4.sh" 