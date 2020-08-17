#!/bin/bash

clear

# don't change this flag!
BUILD_RELEASE_FROM_DEV=0

# check for updates
./check-updates.sh

if [ $? -ne 0 ]; then
    exit 0
fi

# set date
TODAY_DATE="${IMG_DATE:-"$(date +%Y%m%d)"}"

BUILDHASH=`git rev-parse --short HEAD | awk '{print toupper($0)}'`
BUILDBRANCH=`cat ./.git/HEAD | cut -d'/' -f3`
export BUILDHASH
export BUILDBRANCH
export BUILD_RELEASE_FROM_DEV

if [ $BUILD_RELEASE_FROM_DEV -eq 1 ] && [ "$BUILDBRANCH" != "csng-dev" ]; then
    echo "***************************************************************************************"
    echo "You started a release build from dev but your branch is not csng-dev!"
    echo ""
    echo "Abort."
    echo "***************************************************************************************"
    exit 1
fi

# enable all build stages
/bin/rm -f ./stage?/SKIP &>/dev/null

# set build name
# Is/should be set in the config file already.
# echo "IMG_NAME='crankshaft'" > config

# unmount possible left mounts
./build-unmount.sh

# cleanup work dir
echo "***************************************************************************************"
echo "Cleanup work dir..."
rm -rf ./work/$TODAY_DATE-* 2>&1>/dev/null

echo "***************************************************************************************"
echo "Start build..."
echo ""
echo "***************************************************************************************"
echo "    Build Hash: "$BUILDHASH
echo "    Build Date: "$TODAY_DATE
echo "  Build Branch: "$BUILDBRANCH
echo "Build Override: "$BUILD_RELEASE_FROM_DEV
echo "***************************************************************************************"
echo "Current commit crankshaft-ng:"
git log -n1 --no-merges

# check prebuilts
./check-prebuilts.sh

# run pi-gen buildsystem
./build.sh

# unmount possible left mounts
./build-unmount.sh
