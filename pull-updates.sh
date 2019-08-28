#!/bin/bash

NoTimeouts=false

while [ "${1:-}" != "" ]; do
  case "$1" in
    "-n" | "--no-timeouts")
      NoTimeouts=true
      ;;
    "-t" | "--travis-build")
      NoTimeouts=true
      Travis=true
  esac
  shift
done

timeout () {
  if [ "$NoTimeouts" == false ]; then
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
echo "About to pull updates for the Quantify Wear24 NFC AOSP ROM repository..."
echo
echo "If you DO NOT WANT TO update this repository, cancel with CTRL+C NOW!"
timeout 5 "Continuing in %s second(s)..."

echo
echo
echo "Pulling git commits..."
git pull -q

echo 
echo
timeout 4 "Updating repo submodules..."
repo sync -f -c --no-clone-bundle -q -j$((`nproc`*2))
