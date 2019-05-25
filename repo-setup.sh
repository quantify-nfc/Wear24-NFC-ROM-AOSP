#!/bin/bash

NoTimeouts=false

while [ "${1:-}" != "" ]; do
  case "$1" in
    "-n" | "--no-timeouts")
      NoTimeouts=true
      ;;
  esac
  shift
done

timeout () {
  if [ NoTimeouts == false ]; then
    tput sc
    time=$1; while [ $time -ge 0 ]; do
      tput rc; tput el
      printf "$2" $time
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
echo "Thx to osm0sis (mkbootimg), lexri, bensdeals"
echo "And Quanta/AOSP, I suppose :')"
echo "---------------------------------------------------"
timeout 3 "Repo setup begins in %s seconds."

echo
echo
timeout 4 "Setting up git config"
git config core.bigFileThreshold 15m
git config http.postBuffer 157286400

echo 
echo 
timeout 4 "Installing AOSP requirements in %s seconds"
sudo apt install git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip

echo 
echo 
timeout 4 "Installing the Google Repo tool"
mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

echo 
echo 
timeout 4 "Initialising the Repo client"
repo init --depth 1 -b android-wear-7.1.1_r1 -u https://android.googlesource.com/platform/manifest

echo 
echo 
timeout 4 "Synchronising local files with AOSP"
repo sync -c --no-clone-bundle -j$((`nproc`*2))

echo
echo
echo "That should be it!"
echo "To build, run '. build.sh'

