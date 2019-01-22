#!/bin/bash

BASEDIR="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

if [ -d $BASEDIR/prebuilts ]; then
    echo "***************************************************************************************"
    echo "Checking for prebuilt updates..."
    cd prebuilts
    if [ "$BUILDBRANCH" == "csng-dev" ]; then
        git fetch --all >/dev/null 2>&1
        git reset --hard >/dev/null 2>&1
        git clean -f -d >/dev/null 2>&1
        git reset --hard origin/csng-dev >/dev/null 2>&1
    else
        git fetch --all >/dev/null 2>&1
        git reset --hard >/dev/null 2>&1
        git clean -f -d >/dev/null 2>&1
        git reset --hard origin/master >/dev/null 2>&1
    fi
    echo "***************************************************************************************"
    echo "Current commit prebuilts:"
    git log -n 1 --no-merges
    cd $BASEDIR
else
    echo "***************************************************************************************"
    echo "Downloading prebuilts..."
    git clone https://github.com/opencardev/prebuilts
    if [ "$BUILDBRANCH" == "csng-dev" ]; then
        git checkout csng-dev
    else
        git checkout master
    fi
    cd $BASEDIR
fi
echo "***************************************************************************************"
echo "Done"
echo "***************************************************************************************"
