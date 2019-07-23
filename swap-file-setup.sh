#!/bin/bash

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

echo "This script sets up a 16 GB swapfile for your Ubuntu install"
echo "It is recommended that you have more than 16 GB RAM or RAM + swap"
echo
timeout 10 "Starting swapfile setup in %s seconds..."

sudo swapoff -a
sudo fallocate -l 16G /16gswapfile
sudo chmod 600 /16gswapfile
sudo mkswap /16gswapfile
sudo swapon /16gswapfile

set -e
# Check the swap file was added
sudo swapon --show
set +e

# Make it permanent
echo '/16gswapfile none swap sw 0 0' | sudo tee -a /etc/fstab
