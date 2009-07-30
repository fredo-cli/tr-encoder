#!/bin/bash



# create link to be compatible
[[ -z $(readlink "/usr/local/bin/bash") ]] && sudo ln -s /bin/bash /usr/local/bin/bash










 


function INSTALL_MPLAYER(){

sudo apt-get build-dep mplayer-nogui mencoder
sudo apt-get -y purge mplayer-nogui mencoder
cd  
svn checkout  -r $MPLAYER_VERSION  svn://svn.mplayerhq.hu/mplayer/trunk mplayer

cd mplayer

./configure --prefix=/usr

make
sudo checkinstall -y --fstrans=no --install=yes --pkgname=mplayer --pkgversion "$MPLAYER_VERSION_TXT"
sudo ldconfig -v
cd 
#sudo rm -Rf mplayer*
}



function INSTALL_X264 (){
sudo apt-get purge  x264 libx264-dev

cd 
git clone git://git.videolan.org/x264.git
cd x264
./configure --enable-shared
make
sudo checkinstall -y --fstrans=no --install=yes --pkgname=x264 --pkgversion "9.9.9"
sudo ldconfig
cd 
#sudo rm -Rf x264*

}

function INSTALL_YASM(){
cd
wget -nc http://www.tortall.net/projects/yasm/releases/yasm-0.7.2.tar.gz
tar xzvf yasm-0.7.2.tar.gz
cd yasm-0.7.2
./configure
make
sudo checkinstall -y
cd 
sudo -rf rm yasm* 
}

function INSTALL_ATOMICPARSLEY(){
cd
wget -nc  http://archive.ubuntu.com/ubuntu/pool/universe/a/atomicparsley/atomicparsley_0.9.0.orig.tar.gz 
tar xzvf atomicparsley_0.9.0.orig.tar.gz
cd atomicparsley*
./build
sudo cp AtomicParsley /usr/bin
sudo ldconfig
cd 
sudo rm  -Rf atomicparsley* 
}


function OPENCORE_AMR(){
cd 

wget -nc "http://dfn.dl.sourceforge.net/sourceforge/opencore-amr/opencore-amr-0.1.1.tar.gz"
tar xzvf opencore-amr-0.1.1.tar.gz
cd opencore-amr
make
sudo checkinstall -y --fstrans=no --install=yes --pkgname=opencore-mr --pkgversion "0.1.1"

}


function INSTALL_FFMPIP(){



sudo apt-get -y purge ffmpeg 

cd $HOME

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




# --disable-devices --enable-x11grab
#./configure --prefix=/usr --enable-gpl --enable-postproc --enable-pthreads --enable-libfaac --enable-libfaad --enable-libmp3lame --enable-libtheora --enable-libx264 --enable-nonfree  --enable-libamr_nb --enable-libamr_wb  

#work!
#./configure --prefix=/opt/ffmpeg --enable-gpl --enable-postproc --enable-pthreads --enable-libfaac --enable-libfaad --enable-libmp3lame --enable-libtheora --enable-libx264 --enable-nonfree  --enable-libamr_nb --enable-libamr_wb  --disable-shared  --disable-debug  --enable-static --disable-devices --enable-swscale

# work!!! --enable-libgsm pb
./configure --prefix=$HOME/ffmpip --enable-libfaac --enable-libfaad  --enable-libfaadbin --enable-libmp3lame   --enable-libamr_nb --enable-libamr_wb  --enable-libvorbis --enable-libtheora  --enable-libx264 --enable-libxvid  --enable-nonfree  --enable-swscale    --disable-shared  --disable-debug  --enable-static --disable-devices --enable-gpl --enable-postproc --enable-pthreads   --enable-memalign-hack --disable-mmx   --disable-ffplay  --disable-ffserver --disable-ipv6




make



sudo checkinstall -y --fstrans=no --install=yes --pkgname=ffmpip --pkgversion "custom1"



mv ffpresets/ .ffmpeg
cd tools
cc qt-faststart.c -o qt-faststart
sudo cp qt-faststart /usr/bin
cd 
# sudo rm -Rf ffmpeg*

}

function INSTALL_FFMPEG(){

sudo apt-get -y purge ffmpeg 

cd

[[ -d "ffmpeg" ]] && sudo rm -rf ffmpeg


mkdir ffmpeg

cd ffmpeg

svn checkout -r $FFMPEG_VERSION svn://svn.ffmpeg.org/ffmpeg/trunk .





# --disable-devices --enable-x11grab
#./configure  --enable-gpl --enable-postproc --enable-pthreads --enable-libfaac --enable-libfaad --enable-libmp3lame --enable-libtheora --enable-libx264 --enable-nonfree  --enable-libamr_nb --enable-libamr_wb --enable-libopencore-amrwb --enable-version3 --enable-libopencore-amrnb --disable-ffplay --disable-ffserver --enable-avfilter --enable-avfilter-lavf --enable-libfaac --enable-libfaad --enable-libmp3lame --enable-nonfree --enable-libtheora --enable-libvorbis --enable-gpl --enable-libx264 --enable-postproc --enable-pthreads
./configure --disable-devices --enable-shared  --enable-libopencore-amrwb --enable-version3 --enable-libopencore-amrnb --disable-ffplay --disable-ffserver --enable-avfilter --enable-avfilter-lavf --enable-libfaac --enable-libfaad --enable-libmp3lame --enable-nonfree --enable-libtheora --enable-libvorbis --enable-gpl --enable-libx264 --enable-postproc --enable-pthreads
make



sudo checkinstall -y --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "$FFMPEG_VERSION_TXT"
sudo ldconfig -v


mv ffpresets/ .ffmpeg
cd tools
cc qt-faststart.c -o qt-faststart
sudo cp qt-faststart /usr/bin
cd 
# sudo rm -Rf ffmpeg*

}



function INSTALL_MEDIAINFO(){
cd 
wget -nc  http://ovh.dl.sourceforge.net/sourceforge/mediainfo/MediaInfo_CLI_0.7.8_GNU_FromSource.tar.bz2
tar xjvf MediaInfo_CLI_0.7.8_GNU_FromSource.tar.bz2
cd MediaInfo_CLI_GNU_FromSource
sh CLI_Compile.sh
cd MediaInfo/Project/GNU/CLI 
sudo checkinstall -y --fstrans=no --install=yes --pkgname=mediainfo --pkgversion "0.7.8"

sudo rm -rf MediaInfo_CLI*
}



function INSTALL_TR-ENCODER(){
cd 
[[ ! -d  "/home/$USER/tr-encoder/" ]] && svn checkout http://tr-encoder.googlecode.com/svn/trunk/ tr-encoder

sudo ln -sf /home/$USER/tr-encoder/tr-encoder.sh /usr/bin/tr-encoder
chmod +x /home/$USER/tr-encoder/tr-encoder.sh
}




	### test connection ###

	function TEST_CONNEXION(){
	MESSAGE="Internet connextion"
	echo -ne  "$MESSAGE\t"


	wget -q -t 3 http://google.com -O /tmp/testconnexion
	    if [ "$(cat /tmp/testconnexion)" ]; then
	    echo -e "${green}true${NC}"
	    rm /tmp/testconnexion
	    else
	    echo -e "${red}false${NC}"
	    read
	    exit 0
	    fi
	}

        TEST_CONNEXION







	### DEBIAN ###

	#if [[ -z $(cat /etc/apt/sources.list |grep "deb http://www.debian-multimedia.org" ) ]]
	#then
	### not good
	#sudo su -
	#echo "deb http://www.debian-multimedia.org stable main" >> /etc/apt/sources.list
	#exit
	#wget -nc  http://www.debian-multimedia.org/pool/main/d/debian-multimedia-keyring/debian-multimedia-keyring_2008.10.16_all.deb
	#sudo dpkg -i debian-multimedia-keyring_2008.10.16_all.deb
	#rm debian-multimedia-keyring_2008.10.16_all.deb
	#
	#fi




	### add medibuntu ###

	echo -en "medibuntu (jaunty)\t"
	if [[ -z $(cat /etc/apt/sources.list |grep "http://packages.medibuntu.org/ jaunty free non-free" ) ]]
	then

	echo -e "${yellow}false${NC}"

	sudo chmod 777 /etc/apt/sources.list
	echo "deb http://packages.medibuntu.org/ jaunty free non-free" >> /etc/apt/sources.list
	sudo chmod 644 /etc/apt/sources.list

	wget -q http://fr.packages.medibuntu.org/medibuntu-key.gpg -O- | sudo apt-key add -

	else

	echo -e "${green}true${NC}"

	fi








	### update ###

	function ACTIVER_SOURCES(){

		sudo apt-get update

		### hold some pakages
		sudo echo "x264 hold" |sudo  dpkg --set-selections
		sudo echo "ffmpeg hold" |sudo  dpkg --set-selections
		sudo echo "mplayer hold" |sudo  dpkg --set-selections

		echo -e '\nUpdate Sources\n'
		for source in main universe restricted multiverse
		do

		sudo software-properties-gtk -n -e $source > /dev/null 2>&1

		done
		sudo apt-get update
	}

	#ACTIVER_SOURCES








	### verification of dependencies ###

	function VERIF_DEPENDENCES(){
	MESSAGE="Verification dpkg:"
	echo -ne  "$MESSAGE\n"
	MISSING=();

		if [[ "$(lsb_release -si)" == "Ubuntu" ]]
		then
		LISTEDEPENDANCES=(build-essential subversion git-core checkinstall texi2html libfaad-dev libfaac-dev  libmp3lame-dev libtheora-dev gpac atomicparsley flvtool2 libamrnb-dev libamrwb-dev  sox realpath libvorbis-dev imagemagick bc)
		elif [[ "$(lsb_release -si)" == "Debian" ]]
		then
		LISTEDEPENDANCES=(build-essential subversion git-core checkinstall texi2html libfaad-dev libfaac-dev  libmp3lame-dev libtheora-dev gpac  flvtool2 libamrnb-dev libamrwb-dev  sox realpath)
		else
		echo -e "${red}ERROR lsb_release:$(lsb_release -si) != Ubuntu|Debian ${NC}" ;

		read
		exit 0
		fi


		i=0
		while (( i < ${#LISTEDEPENDANCES[@]} ))
		do
		DPKG="${LISTEDEPENDANCES[$i]}"
		TEST=`dpkg -s $DPKG | grep -i "Status"`
			
			(( i = i + 1 ))
			echo -en "${DPKG}\t" ;
			if ! [ "${TEST}" == "Status: install ok installed" ]; then
			echo -e "${red}false${NC}"
			MISSING=(${MISSING[@]} ${DPKG})
			else
			echo -e "${green}true${NC}" ;
			fi

		done


	if ! [ -z "${MISSING}" ]; then


	INSTALL_DEP="y"

	INSTALLER="${MISSING[@]}"
	echo -e "${yellow}to install all packages missing:${NC}\nsudo apt-get install -y $INSTALLER"

	echo "Do you whant to install them? [Y/n]"
	read -t 10 INSTALL_DEP


		if [[ "${INSTALL_DEP}" == "y" || "${INSTALL_DEP}" == "Y" ]]; then
		INSTALLER=$(echo -e "$INSTALLER" | grep -v "^#" | xargs)
		INSTALLER=(${INSTALLER[@]})
		i=0
			while (( i < ${#INSTALLER[@]} ))
			do
			echo "${INSTALLER[$i]}"
			sudo apt-get install -y --force-yes ${INSTALLER[$i]}
			sudo apt-get clean &>/dev/null
			(( i = i + 1 ))
			done
			
		sudo apt-get autoremove -y &>/dev/null
		sudo apt-get autoclean &>/dev/null
		fi
		

	fi
	}
	VERIF_DEPENDENCES





	### Mplayer ###
 
	echo -en "mplayer (svn)\t"
	if [[ $(dpkg -s mplayer| grep Version:) != "Version: $MPLAYER_VERSION_TXT-1" ]]
	then
	echo -e "${yellow}false${NC}"
	[[ $INSTALL == 1 ]] && INSTALL_MPLAYER
	else
	echo -e "${green}true${NC}"
	fi



	### Atomicparsley ###

	echo -en "Atomicparsley\t"
	if [[ -z $(which AtomicParsley) ]]
	then
	echo -e "${yellow}false${NC}"
	[[ $INSTALL == 1 ]] && INSTALL_ATOMICPARSLEY
	else
	echo -e "${green}true${NC}"
	fi





	### x264 ###

	echo -en "x264\t"
	if [[ $(dpkg -s x264| grep Version:) != "Version: 9.9.9-1" ]]
	then
	echo -e "${yellow}false${NC}"
	[[ $INSTALL == 1 ]] &&  INSTALL_X264
	else
	echo -e "${green}true${NC}"
	fi




	### tr-encoder ###

	echo -en "tr-encoder\t"
	if [[ -z $(which tr-encoder) ]]
	then
	echo -e "${yellow}false${NC}"
	[[ $INSTALL == 1 ]] && INSTALL_TR-ENCODER
	else
	echo -e "${green}true${NC}"
	fi





	### libopencore ###

	echo -en "libopencore\t"

	if [[ -f "/usr/local/lib/libopencore-amrnb.so" ]]
	then

	echo -e "${green}true${NC}"

	else

	echo -e "${yellow}false${NC}"

	[[ $INSTALL == 1 ]] && OPENCORE_AMR

	fi





	### yasm ###

	echo -en "yasm\t"
	if [[ $(dpkg -s yasm| grep Version:) != "Version: 0.7.2-1" ]]
	then
	echo -e "${yellow}false${NC}"
	[[ $INSTALL == 1 ]] && INSTALL_YASM
	else
	echo -e "${green}true${NC}"
	fi





	### ffmpeg ###

	echo -en "ffmpeg\t"
	if [[ $(dpkg -s ffmpeg| grep Version:) != "Version: $FFMPEG_VERSION_TXT-1" && $(dpkg -s ffmpip| grep Version:) != "Version: $FFMPEG_VERSION_TXT-1" ]]
	then
	echo -e "${yellow}false${NC}"

		if [[ $INSTALL == 1 ]]
		then

cat << EOF
1  ffmpeg + pip = ffmpip
2  SVN ffmpeg latest

EOF


		CHOICE=0
		read CHOICE

		
		case $CHOICE in

		1)INSTALL_FFMPIP;;

		2)INSTALL_FFMPEG;;

		*)echo -e "${yellow}ffmpeg install cancel ${NC}";;

		esac

		fi
	else
	echo -e "${green}true${NC}"
	fi





	### mediainfo ###

	echo -en "mediainfo\t"
	if [[ $(dpkg -s mediainfo| grep Version:) != "Version: 0.7.8-1" ]]
	then
	echo -e "${yellow}false${NC}"
	[[ $INSTALL == 1 ]] && INSTALL_MEDIAINFO
	else
	echo -e "${green}true${NC}"
	fi






cd

echo "Press any keys to exit"
[[ $INSTALL == 0 ]] && echo "bash $0 -i to install missing packages"
read
exit