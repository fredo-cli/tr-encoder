#!/usr/local/bin/bash


	### portsnap ###

	function PORTSNAP(){
	sudo su -
	# install portsnap if needed
	#pkg_add -r portsnap
	#mkdir /usr/ports
	#portsnap fetch
	#portsnap extract

	portsnap fetch
	portsnap update
	}






	### ruby-flvtool2

	echo -en "ruby-flvtool2\t"
	if [[ ! -z $(which flvtool2) ]]
	then

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^ruby-flvtool2 |awk -F " " '{print $1}'))"
	[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/ruby-flvtool2/ && make deinstall && sudo make install clean

	else

	echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^ruby-flvtool2 |awk -F " " '{print $1}'))"
	[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/ruby-flvtool2/ && sudo make install clean

	fi






	### faac

	echo -en "faac\t"
	if [[ ! -z $(which faac) ]]
	then

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^faac- |awk -F " " '{print $1}'))"
	[[ $REINSTALL == 1 ]] && cd /usr/ports/audio/faac/ && make deinstall && sudo make install clean

	else

	echo -e "${yellow}false${NC}\t"
	[[ $INSTALL == 1 ]] && cd /usr/ports/audio/faac/ && sudo make install clean

	fi






	### faacd

	echo -en "faad\t"
	if [[ ! -z $(which faad) ]]
	then

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^faad2- |awk -F " " '{print $1}'))"
	[[ $REINSTALL == 1 ]] && cd /usr/ports/audio/faad/ && make deinstall && sudo make install clean

	else

	echo -e "${yellow}false${NC}\t"
	[[ $INSTALL == 1 ]] && cd /usr/ports/audio/faad/ && sudo make install clean

	fi






	###  AtomicParsley 

	echo -en "AtomicParsley\t"
	if [[ ! -z $(which AtomicParsley) ]]
	then

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^AtomicParsley |awk -F " " '{print $1}'))"
	[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/atomicparsley/ && make deinstall && sudo make install clean

	else

	echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^AtomicParsley |awk -F " " '{print $1}'))"
	[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/atomicparsley/ && sudo make install clean

	fi






	### Check if sox is installed

	echo -en "sox\t"

	if [[ ! -z $(which sox) ]]
	then

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^sox- |awk -F " " '{print $1}'))"
	[[ $REINSTALL == 1 ]] && cd /usr/ports/audio/sox && make deinstall && sudo make install clean

	else

	echo -e "${yellow}false${NC}\t"
	[[ $INSTALL == 1 ]] && cd /usr/ports/audio/sox && sudo make install clean

	fi


        function INSTALL_MEDIAINFO(){

            cd $HOME
            wget -nc  http://ovh.dl.sourceforge.net/sourceforge/mediainfo/MediaInfo_CLI_0.7.8_GNU_FromSource.tar.bz2
            tar xjvf MediaInfo_CLI_0.7.8_GNU_FromSource.tar.bz2
            cd MediaInfo_CLI_GNU_FromSource
            sh CLI_Compile.sh
            cd MediaInfo/Project/GNU/CLI
            sudo make install
            cd $HOME
            sudo rm -rf MediaInfo_CLI*

        }



	### mediainfo

	echo -en "mediainfo\t"

	if [[ ! -z $(which mediainfo) ]]
	then

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^mediainfo- |awk -F " " '{print $1}'))"
	#   [[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/mediainfo/ && make deinstall && sudo make install clean
            [[ $REINSTALL == 1 ]] && MEDIAINFO
	else

	echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^mediainfo- |awk -F " " '{print $1}'))"
            #[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/mediainfo/ && sudo make install clean
             [[ $INSTALL == 1 ]] && MEDIAINFO
	fi









	### mp4box

	echo -en "gpac-mp4box\t"

	if [[ ! -z $(which mp4box) ]]
	then

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^gpac-mp4box- |awk -F " " '{print $1}'))"
	[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/gpac-mp4box && make deinstall && sudo make install clean

	else

	echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^gpac-mp4box- |awk -F " " '{print $1}'))"
	[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/gpac-mp4box && sudo make install clean

	fi






	### readlink

	echo -en "readlink\t"

	if [[ ! -z $(which readlink) ]]
	then

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^readlink- |awk -F " " '{print $1}'))"
	[[ $REINSTALL == 1 ]] && cd /usr/ports/sysutils/readlink && make deinstall && sudo make install clean

	else

	echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^readlink- |awk -F " " '{print $1}'))"
	[[ $INSTALL == 1 ]] && cd /usr/ports/sysutils/readlink && sudo make install clean

	fi






	### seq2

	echo -en "seq2\t"

	if [[ ! -z $(which seq2) ]]
	then

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^seq2- |awk -F " " '{print $1}'))"
	[[ $REINSTALL == 1 ]] && cd /usr/ports/misc/seq2 && make deinstall && sudo make install clean

	else

	echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^seq2- |awk -F " " '{print $1}'))"
	[[ $INSTALL == 1 ]] && cd /usr/ports/misc/seq2 && sudo make install clean

	fi






	### md5

	echo -en "md5 (cfv)\t"

	if [[ -z $(which cfv) ]]
	then


	echo -e "${yellow}false${NC}\t"
	[[ $INSTALL == 1 ]] && cd /usr/ports/security/cfv && sudo make install clean

	else

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^cfv- |awk -F " " '{print $1}'))"
	[[ $REINSTALL == 1 ]] && cd /usr/ports/security/cfv && make deinstall && sudo make install clean

	fi






	### x264 ###

	echo -en "x264\t"
	if [[ ! -z $(which x264) && $(x264 --version |grep x264 |grep -o [0-9]\\.[0-9]*) == $X264_VERSION ]]
	then

	echo -e "${green}true${NC}\t($(pkg_version  -vs ^x264- |awk -F " " '{print $1}')) $(x264 --version |grep x264 |grep -o [0-9]\\.[0-9]*)"
	[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/x264 && make deinstall && sudo make install clean

	else

	echo -e "${yellow}false${NC}\t"

	[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/x264 && sudo make install clean

	fi












	### lame ###

	function INSTALL_LAME(){

	cd
	wget http://freefr.dl.sourceforge.net/sourceforge/lame/lame-398.tar.gz -O - | tar xzf -
	cd lame-398
	./configure --enable-shared --enable-static
	sudo gmake
	sudo gmake install

	} 


	### Check the version of lame

	echo -en "lame\t"
	LAME_VERSION_DETECTED=$(lame --longhelp|grep -o "version [0-9.]\{4,\}")

	#if [[ -z $(lame --longhelp|grep "version" |grep  -o "3.98 ") ]]
	if [[ -z $(pkg_version  -vs ^lame- |grep  -o $LAME_VERSION) ]]
	then 

	echo -e "${yellow}false${NC}\t($LAME_VERSION_DETECTED)"
	[[ $INSTALL == 1 ]] && INSTALL_LAME

	else

	echo -e "${green}true${NC}\t($LAME_VERSION_DETECTED)"
	[[ $REINSTALL == 1 ]] && INSTALL_LAME

	fi






	### mplayer ###

	function INSTALL_MPLAYER(){

	cd  
	svn checkout -r  $MPLAYER_VERSION  svn://svn.mplayerhq.hu/mplayer/trunk mplayer
	cd mplayer
	./configure 
	gmake
	sudo  su root -c 'gmake install'

	}

	### Check the version of mplayer

	echo -en "mplayer\t"
	MPLAYER_VERSION_DETECTED=$(mplayer |grep -o "MPlayer SVN-r$MPLAYER_VERSION" |grep -o "$MPLAYER_VERSION")


	if [[ "$MPLAYER_VERSION_DETECTED" != "$MPLAYER_VERSION" ]]
	then 
	echo -e "${yellow}false${NC}\t($MPLAYER_VERSION_DETECTED)"
	[[ $INSTALL == 1 ]] && INSTALL_MPLAYER
	else
	echo -e "${green}true${NC}\t($MPLAYER_VERSION_DETECTED)"
	[[ $REINSTALL == 1 ]] && INSTALL_MPLAYER
	fi







	### tr-encoder ###

	function INSTALL_TR-ENCODER(){
	cd 
	svn checkout http://tr-encoder.googlecode.com/svn/trunk/ tr-encoder
	sudo ln -sf /home/fred/tr-encoder/tr-encoder.sh /usr/bin/tr-encoder
	chmod +x /home/fred/tr-encoder/tr-encoder.sh
	}

	### Check if tr-encoder  is installed

	echo -en "tr-encoder\t"
	if [[ ! -z $(which tr-encoder) ]]
	then
	echo -e "${green}true${NC}\t"
	[[ $REINSTALL == 1 ]] && INSTALL_TR-ENCODER
	else
	echo -e "${yellow}false${NC}\t"
	[[ $INSTALL == 1 ]] && INSTALL_TR-ENCODER
	fi












	### ffmpeg ###

	function INSTALL_FFMPEG(){

	cd "$HOME"

	[[ -d "ffmpeg" ]] && sudo rm -rf ffmpeg

	wget -nc  http://dl.getdropbox.com/u/221284/ffmpeg.tar.gz
	tar -xzvf ffmpeg.tar.gz 


	cd "$HOME/ffmpeg/"



	svn checkout -r $FFMPEG_VERSION svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg


	cd "$HOME/ffmpeg/ffmpeg/"

	rm -rf libswscale
	svn checkout -r 28999 svn://svn.ffmpeg.org/mplayer/trunk/libswscale libswscale

	### patch wma3

	cd "$HOME/ffmpeg/ffmpeg/libavcodec"
	ln -s ../../wma3dec.c wma3dec.c
	ln -s ../../wma3data.h wma3data.h
	ln -s ../../wma3.h wma3.h

	cd "$HOME/ffmpeg/ffmpeg/"
	patch -p0 <../wmapro_ffmpeg.patch
	patch -p0 <../audioframesize.patch

	### patch pip

	cd  "$HOME/ffmpeg/ffmpeg/vhook"
	ln -s  ../../pip1.2.1.c pip.c

	cd  "$HOME/ffmpeg/ffmpeg"
	patch -p0  <  ../pip.patch





	./configure --prefix="$HOME/ffmpip" --extra-cflags="-I/usr/local/include/vorbis -I/usr/local/include" --extra-ldflags="-L/usr/local/lib -la52" --enable-libfaac --enable-libfaad  --enable-libfaadbin --enable-libmp3lame   --enable-libamr_nb --enable-libamr_wb  --enable-libvorbis --enable-libtheora  --enable-libx264 --enable-libxvid  --enable-nonfree  --enable-swscale    --disable-shared  --disable-debug  --enable-static --disable-devices --enable-gpl --enable-postproc --enable-pthreads   --enable-memalign-hack --enable-mmx   --disable-ffplay  --disable-ffserver --disable-ipv6 --enable-libgsm 

	gmake
	sudo gmake install

	sudo ln -s "$HOME/ffmpip/bin/ffmpeg"  "/usr/local/bin/ffmpip"


	cp  -r ffpresets "$HOME/.ffmpeg"
	cd tools
	cc qt-faststart.c -o qt-faststart
	sudo cp qt-faststart /usr/bin
	cd 

	}

	echo -en "ffmpeg (alias ffmpip)\t"

	FFMPEG_INSTALLED=$(ffmpip -i 2>&1 |grep FFmpeg |grep -o SVN-r[0-9]* )
	if [[ $FFMPEG_INSTALLED != "SVN-r$FFMPEG_VERSION" ]]
	then

	echo -e "${yellow}false${NC}\t($FFMPEG_INSTALLED)"
	[[ $INSTALL == 1 ]] && INSTALL_FFMPEG

	else

	echo -e "${green}true${NC}\t($FFMPEG_INSTALLED)"

	fi








      ### ImageMagick-6.5.2 ###

      INSTALL_IMAGEMAGICK(){

      cd $HOME
      svn co https://www.imagemagick.org/subversion/ImageMagick/branches/ImageMagick-6.5.1 ImageMagick-6.5.1
      cd ImageMagick-6.5.1
      ./configure
      gmake
      sudo gmake install
      cd

      }

	echo -en "ImageMagick\t"

	IMAGEMAGICK_INSTALLED=$(convert -v|grep Version:|grep -o "[0-9]*\.[0-9]*\.[0-9]*")
	if [[ $IMAGEMAGICK_INSTALLED != $IMAGEMAGICK_VERSION ]]
	then

	echo -e "${yellow}false${NC}\t($IMAGEMAGICK_INSTALLED <> $IMAGEMAGICK_VERSION )"
	[[ $INSTALL == 1 ]] && INSTALL_IMAGEMAGICK

	else

	echo -e "${green}true${NC}\t($IMAGEMAGICK_INSTALLED)"

	fi








      ### end ###
      cd

      echo "Press any keys to exit"
      [[ $INSTALL == 0 ]] && echo "bash $0 -i to install missing packages"
      read
      exit









