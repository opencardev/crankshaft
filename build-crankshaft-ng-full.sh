#!/bin/bash

# check for updates
./check-updates.sh

if [ $? -ne 0 ]; then
    exit 0
fi

# set date
TODAY_DATE="${IMG_DATE:-"$(date +%Y-%m-%d)"}"

BUILDHASH=`git rev-parse --short HEAD | awk '{print toupper($0)}'`
export BUILDHASH

# enable all build stages
rm ./stage0/SKIP &>/dev/null
rm ./stage1/SKIP &>/dev/null
rm ./stage2/SKIP &>/dev/null
rm ./stage3/SKIP &>/dev/null

# set build name
echo "IMG_NAME='crankshaft'" > config

# unmount possible left mounts
./build-unmount.sh

# cleanup work dir
rm -rf ./work/$TODAY_DATE-* 2>&1>/dev/null

clear
echo "***************************************************************************************"
echo "Start build..."
echo "***************************************************************************************"
echo ""
echo "***************************************************************************************"
echo "Build Hash: "$BUILDHASH
echo "Build Date: "$TODAY_DATE
echo "***************************************************************************************"

# check prebuilts
./check-prebuilts.sh

# run pi-gen buildsystem
./build.sh

# unmount possible left mounts
./build-unmount.sh
