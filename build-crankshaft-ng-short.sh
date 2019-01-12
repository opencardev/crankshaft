#!/bin/bash

# check for updates
./check-updates.sh

if [ $? -ne 0 ]; then
    exit 0
fi

# set date
TODAY_DATE="${IMG_DATE:-"$(date +%Y-%m-%d)"}"

BUILDHASH=`git rev-parse --short HEAD | awk '{print toupper($0)}'`
BUILDBRANCH=`cat ./.git/HEAD | cut -d'/' -f3`
export BUILDHASH
export BUILDBRANCH

# enable all build stages
touch ./stage0/SKIP &>/dev/null
touch ./stage1/SKIP &>/dev/null
touch ./stage2/SKIP &>/dev/null
rm ./stage3/SKIP &>/dev/null
rm ./stage4/SKIP &>/dev/null

# set build name
echo "IMG_NAME='crankshaft'" > config

# unmount possible left mounts
./build-unmount.sh

# cleanup work dir
rm -rf ./work/$TODAY_DATE-*/stage3 2>&1>/dev/null
rm -rf ./work/$TODAY_DATE-*/stage4 2>&1>/dev/null
rm -rf ./work/$TODAY_DATE-*/export-image 2>&1>/dev/null

clear
echo "***************************************************************************************"
echo "Start build..."
echo "***************************************************************************************"
echo ""
echo "***************************************************************************************"
echo "Build Hash:   "$BUILDHASH
echo "Build Date:   "$TODAY_DATE
echo "Build Branch: "$BUILDBRANCH
echo ""
git log -n1 --no-merges
echo "***************************************************************************************"

# check prebuilts
./check-prebuilts.sh

# run pi-gen buildsystem
./build.sh

# unmount possible left mounts
./build-unmount.sh
