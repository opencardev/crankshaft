#!/bin/bash

BASEDIR="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

if [ -d $BASEDIR/prebuilts ]; then
    echo "***************************************************************************************"
    echo "Checking for prebuilt updates..."
    echo "***************************************************************************************"
    cd prebuilts
    if [ "$BUILDBRANCH" == "csng-dev" ]; then
        git reset --hard >/dev/null 2>&1
        git checkout csng-dev >/dev/null 2>&1
        git reset --hard HEAD~1 >/dev/null 2>&1
        git clean -f -d >/dev/null 2>&1
        git pull >/dev/null 2>&1
        echo "***************************************************************************************"
        echo "Current commit:"
        echo "***************************************************************************************"
        git log -n 1 --no-merges
    else
        git reset --hard >/dev/null 2>&1
        git checkout master >/dev/null 2>&1
        git reset --hard HEAD~1 >/dev/null 2>&1
        git clean -f -d >/dev/null 2>&1
        git pull >/dev/null 2>&1
        echo "***************************************************************************************"
        echo "Current commit:"
        echo "***************************************************************************************"
        git log -n 1 --no-merges
    fi
    cd $BASEDIR
else
    echo "***************************************************************************************"
    echo "Downloading prebuilts..."
    echo "***************************************************************************************"
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
