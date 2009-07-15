#!/bin/bash

LAME_VERSION=3.98
FFMPEG_VERSION=19433
FFMPEG_VERSION_TXT="opencore"
X264_VERSION=0.65
MPLAYER_VERSION=29242


# create link to be compatible
[[ -z $(readlink "/usr/local/bin/bash") ]] && sudo ln -s /bin/bash /usr/local/bin/bash










 


function INSTALL_MPLAYER(){
sudo apt-get -y purge mplayer 
cd  
svn checkout  -r $MPLAYER_VERSION  svn://svn.mplayerhq.hu/mplayer/trunk mplayer

cd mplayer
./configure
make
sudo checkinstall -y --fstrans=no --install=yes --pkgname=mplayer --pkgversion "$MPLAYER_VERSION"
sudo ldconfig
cd 
sudo rm -Rf mplayer*
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
sudo rm -Rf x264*

}

function INSTALL_YASM(){
cd
wget http://www.tortall.net/projects/yasm/releases/yasm-0.7.2.tar.gz
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
wget http://archive.ubuntu.com/ubuntu/pool/universe/a/atomicparsley/atomicparsley_0.9.0.orig.tar.gz | tar xzvf
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

wget "http://dfn.dl.sourceforge.net/sourceforge/opencore-amr/opencore-amr-0.1.1.tar.gz"
tar xzvf opencore-amr-0.1.1.tar.gz
cd opencore-amr
make
sudo ldconfig
}


function INSTALL_FFMPEG_old(){

sudo apt-get -y purge ffmpeg 

cd

[[ -d "ffmpeg" ]] && rm -rf ffmpeg




wget http://dl.getdropbox.com/u/221284/ffmpeg.tar.gz

tar -xzvf ffmpeg.tar.gz 


cd ffmpeg

# Version 0.5
#FFMPEG_VERSION=17737
svn checkout -r $FFMPEG_VERSION svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg

##  old release
## -r 10657
## -r 14424 freebsd
## svn -r 17727 = version 0.5 -> not good
## svn -r 17768 = last version before removing vhook -> not good
## svn -r 17792 =  version recommanded for libavfilter




### patch wma3

cd ffmpeg/libavcodec
ln -s ../../wma3dec.c wma3dec.c
ln -s ../../wma3data.h wma3data.h
ln -s ../../wma3.h wma3.h
cd ../
patch -p0 <../wmapro_ffmpeg.patch
patch -p0 <../audioframesize.patch

### patch pip
cd ./vhook
ln -s  ../../pip1.2.1.c pip.c
cd ../
patch -p0  <  ../pip.patch




# --disable-devices --enable-x11grab
./configure  --enable-gpl --enable-postproc --enable-pthreads --enable-libfaac --enable-libfaad --enable-libmp3lame --enable-libtheora --enable-libx264 --enable-nonfree  --enable-libamr_nb --enable-libamr_wb  

make



sudo checkinstall -y --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "$FFMPEG_VERSION+vhook+pip+wm3a"



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
./configure --enable-libopencore-amrwb --enable-version3 --enable-libopencore-amrnb --disable-ffplay --disable-ffserver --enable-avfilter --enable-avfilter-lavf --enable-libfaac --enable-libfaad --enable-libmp3lame --enable-nonfree --enable-libtheora --enable-libvorbis --enable-gpl --enable-libx264 --enable-postproc --enable-pthreads
make



sudo checkinstall -y --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "$FFMPEG_VERSION+$FFMPEG_VERSION_TXT"



mv ffpresets/ .ffmpeg
cd tools
cc qt-faststart.c -o qt-faststart
sudo cp qt-faststart /usr/bin
cd 
# sudo rm -Rf ffmpeg*

}



function INSTALL_MEDIAINFO(){
cd 
wget http://ovh.dl.sourceforge.net/sourceforge/mediainfo/MediaInfo_CLI_0.7.8_GNU_FromSource.tar.bz2
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
	#wget http://www.debian-multimedia.org/pool/main/d/debian-multimedia-keyring/debian-multimedia-keyring_2008.10.16_all.deb
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
		LISTEDEPENDANCES=(build-essential subversion git-core checkinstall texi2html libfaad-dev libfaac-dev  libmp3lame-dev libtheora-dev gpac atomicparsley flvtool2 libamrnb-dev libamrwb-dev  sox realpath)
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
	if [[ $(dpkg -s mplayer| grep Version:) != "Version: $MPLAYER_VERSION-1" ]]
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
	OPENCORE_AMR

	fi





	### libopencore ###

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
	if [[ $(dpkg -s ffmpeg| grep Version:) != "Version: $FFMPEG_VERSION+$FFMPEG_VERSION_TXT" ]]
	then
	echo -e "${yellow}false${NC}"

		if [[ $INSTALL == 1 ]]
		then

cat << EOF
1  SVN $FFMPEG_VERSION+$FFMPEG_VERSION_TXT
2  SVN $FFMPEG_VERSION_old

EOF


		CHOICE=0
		read -t 30 CHOICE
		echo $CHOICE
		
		case $CHOICE in

		1)INSTALL_FFMPEG;;

		2)INSTALL_FFMPEG_old;;

		*)echo -e "${yellow}escape${NC}";;

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