#!/bin/bash
set -e

NoTimeouts=false
DistBuild=false
SkipKernelBuild=false

while [ "${1:-}" != "" ]; do
  case "$1" in
    "-n" | "--no-timeouts")
      NoTimeouts=true
      ;;
    "-d" | "--dist" | "--ota")
      DistBuild=true
      ;;
    "--skip-kernel")
      SkipKernelBuild=true
      ;;
  esac
  shift
done

timeout () {
  if [ "$NoTimeouts" == false ]; then
    tput sc
    time=$1; while [ "$time" -ge 0 ]; do 
      tput rc; tput el
      printf "$2" "$time"
      ((time--))
      sleep 1
    done
    tput rc; tput ed;
  else
    echo "*** Timeout skipped! ***"
  fi
}

clear
echo "Quantify | The \"official\" Wear24 ROM Project"
echo "WIP by JaredTamana and davwheat (XDA)"
echo "Thanks to osm0sis (mkbootimg) & mkorenko (some dorado makefiles)"
echo "Special thanks to lexri for helping us with everything else"
echo "Thanks to bensdeals for your kind donation!"
echo "And Quanta/AOSP, I suppose :')"
echo "----------------------------------------------------------------"

if [ ! -d ".quantifyinit" ]; then
  echo "Running through init..."
  mkdir .quantifyinit
  
  echo
  echo
  echo "Installing Jack server if not present..."
  if [ ! -d "$HOME/.jack-server" ]; then
    cd prebuilts/sdk/tools
    ./jack-admin install-server jack-launcher.jar jack-server-4.8.ALPHA.jar
    cd ../../../
  fi
  touch .quantifyinit/jackinstalled
  
  # set up ccache, if it hasn't been set up already
    
  if [ "$CI" == true ]; then
    if [ ! -f ".quantifyinit/ccacheset" ]; then
      res="	"
      export USE_CCACHE=1 && echo -n "yes$res" >> .quantifyinit/ccacheset
      choice=25G
      echo -n "$choice$res" >> .quantifyinit/ccacheset
      prebuilts/misc/linux-x86/ccache/ccache -M $choice
      export CCACHE_COMPRESS=1 && echo -n "yes$res" >> .quantifyinit/ccacheset && echo "Enabled ccache compression.";
    else
      export USE_CCACHE=1
      echo "ccache is enabled"
      ccache -M "$(cut -f2 .quantifyinit/ccacheset)"
      export CCACHE_COMPRESS=1
      echo "ccache compression is enabled"
    fi
  else  
    if [ ! -f ".quantifyinit/ccacheset" ]; then
      CCACHE_REGEX="[0-9][0-9][0-9]?[Gg]?[Bb]?"
      res="	"
      read -r -p "Use ccache to speed up builds (y/n)? " choice
      case "$choice" in
        y|Y ) export USE_CCACHE=1 && echo -n "yes$res" >> .quantifyinit/ccacheset;;
        n|N ) echo "Did not set ccache" && touch .quantifyinit/ccacheset;;
        * ) echo "Invalid" && rm -rf .quantifyinit && exit 1;;
      esac
    
      if [ "$(cut -f1 .quantifyinit/ccacheset)" == "yes" ]; then
        read -r -p "How much cache? (10-999GB) " choice
        if [[ $choice =~ $CCACHE_REGEX ]]; then
          choice=${choice%G*} # delete any characters starting with G
          choice=${choice}G
          echo -n "$choice$res" >> .quantifyinit/ccacheset
          prebuilts/misc/linux-x86/ccache/ccache -M "$choice"
          read -r -p "Enable compression (y/n)? " choice
          case "$choice" in
            y|Y ) export CCACHE_COMPRESS=1 && echo -n "yes$res" >> .quantifyinit/ccacheset && echo "Enabled ccache compression.";;
            n|N ) echo "Did not enable compression";;
            * ) echo "Invalid, did not enable compression.";;
          esac        
        else
          echo "Did not match format! Resetting init and exiting..."
          rm -rf .quantifyinit
          exit 1
        fi # match regex
      fi # cut match
    fi # ccacheset exists
  fi # travis build
else # .quantifyinit does exist, don't overwrite
  if [ "$(cut -f1 .quantifyinit/ccacheset)" == "yes" ]; then
    export USE_CCACHE=1
    echo "ccache is enabled"
    prebuilts/misc/linux-x86/ccache/ccache -M "$(cut -f2 .quantifyinit/ccacheset)"
  fi
  if [ "$(cut -f3 .quantifyinit/ccacheset)" == "yes" ]; then
    export CCACHE_COMPRESS=1
    echo "ccache compression is enabled"
  fi
fi

if [[ $SkipKernelBuild = false ]]; then
  echo "Starting kernel build"
  cd kernel/build
  ./build.sh
  cd ../../
else
  echo "Option \"--skip-kernel\" was passed."
  echo "*** SKIPPING KERNEL BUILD ***"
fi

# Building on Ubuntu 18.04 causes an issue with the flex prebuilt package
# This fixes it for some strange reason that none of us question because it lets us build AOSP :)
export LC_ALL=C

set +e


if [ $DistBuild = true ]; then
  echo
  echo "**********************"
  echo "*     DIST BUILD     *"
  echo "**********************"
  echo
fi

timeout 5 "AOSP build begins in %s seconds."

# Setup build environment
echo
echo
echo "Setting up build environment..."
. build/envsetup.sh

# Set Java max heap size to 7GB (or AOSP won't build/fail at ~40-80%)
echo
echo
echo "Setting up Jack variables..."
export ANDROID_JACK_VM_ARGS="-Xmx7G -Xms1G -Dfile.encoding=UTF-8 -XX:+TieredCompilation"
export SERVER_NB_COMPILE=6 # increase parallel jack compilations 4 -> 6
export JACK_SERVER_VM_ARGUMENTS=$ANDROID_JACK_VM_ARGS

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

# Build kernel
echo
echo
echo "Building Quantify kernel, logs can be found at kernelbuild.log"
cd kernel/build
rm kernelbuild.log
./build.sh | tee -a ../../kernelbuild.log

# Copy built kernel to AOSP
cd ../..
cp kernel/build/out/zImage-dtb device/quanta/dorado-kernel/zImage-dtb

# export built kernel path so AOSP doesn't build the default one
export TARGET_PREBUILT_KERNEL=device/quanta/dorado-kernel/zImage-dtb

# Build with (total cores * 3) concurrent jobs
echo
echo
echo "Building AOSP with $(($(nproc)*3)) concurrent jobs..."
echo "Build log can be found at aospbuild.log"
rm aospbuild.log

if [ $DistBuild = true ]; then
  echo "Creating distribution files..."
  m -j$(($(nproc)*3)) dist | tee -a aospbuild.log
  echo "Compiling OTA update zip"
  ./build/tools/releasetools/ota_from_target_files out/dist/full_dorado-target_files-eng.*.zip ota_update.zip
else
  m -j$(($(nproc)*3)) | tee -a aospbuild.log
fi
