#!/bin/bash

timeout () {
    tput sc
    time=$1; while [ $time -ge 0 ]; do
        tput rc; tput el
        printf "$2" $time
        ((time--))
        sleep 1
    done
    tput rc; tput ed;
}

clear
echo "Quantify | The \"official\" Wear24 ROM Project"
echo "WIP by JaredTamana and davwheat (XDA)"
echo "Thanks to osm0sis (mkbootimg) & mkorenko (some dorado makefiles)"
echo "Special thanks to lexri for helping us with everything else"
echo "Thanks to bensdeals for your kind donation!"
echo "And Quanta/AOSP, I suppose :')"
echo "---------------------------------------------------"
timeout 5 "AOSP build begins in %s seconds."

# Setup build environment
echo
echo
echo "Setting up build environment..."
. build/envsetup.sh

# install jack server if it isn't present
echo
echo
echo "Installing Jack server..."
if [ ! -d "~/.jack-server" ]; then
	cd prebuilts/sdk/tools
	./jack-admin install-server jack-launcher.jar jack-server-4.8.ALPHA.jar
	cd ../../../
fi

# Set Java max heap size to 8GB (or AOSP won't build/fail at ~40-80%)
echo
echo
echo "Setting up Jack variables..."
export ANDROID_JACK_VM_ARGS="-Xmx8G -Xms1G -Dfile.encoding=UTF-8 -XX:+TieredCompilation"
export JACK_SERVER_VM_ARGUMENTS="-Xmx8G -Xms1G -Dfile.encoding=UTF-8 -XX:+TieredCompilation"

# set up ccache, if it hasn't been set up already

if [ ! -f ".ccacheset" ]; then
	read -p "Use ccache to speed up builds (y/n)?" choice
	case "$choice" in 
  	y|Y ) export USE_CCACHE=1 && touch .ccacheset && echo "yes" > .ccacheset;;
  	n|N ) echo "Did not set ccache" && touch .ccacheset;;
  	* ) echo "Invalid" && exit 1;;
	esac
	
	if [ cat .ccacheset == "yes" ]; then
		read -p "How much cache? (use syntax ###G, ie 25G)" choice
		ccache -M $choice
		read -p "Enable compression (y/n)?" choice
		case "$choice" in
		y|Y ) export CCACHE_COMPRESS=1;;
		n|N ) echo "Did not enable compression"
		* ) echo "Invalid, did not enable compression."
	fi
	echo "To run through ccache setup again, remove the .ccacheset file"
fi

	

# Restart the Jack server to use the new arguments
echo
echo
echo "Restarting Jack server"
./prebuilts/sdk/tools/jack-admin kill-server
./prebuilts/sdk/tools/jack-admin start-server

# Make clobber (because why not)
echo
echo
echo "Cleaning up directory..."
m clobber

# Select the dorado product
echo
echo
echo "Preparing dorado build..."
lunch full_dorado-userdebug

# Build with (total cores * 8) concurrent jobs
echo
echo
echo "Building AOSP with $((`nproc`*8)) concurrent jobs..."
m -j$((`nproc`*8))
