#!/bin/bash

LOCALE=`git log -n 1 --pretty=format:"%H"`
REMOTE=`git ls-remote git://github.com/opencardev/crankshaft.git | grep refs/heads/crankshaft-ng | cut -f 1`

if [ $LOCALE == $REMOTE ]; then
    echo "***************************************************************************************"
    echo "Locale repo clone is up-to-date"
    echo "***************************************************************************************"
else
    clear
    echo "***************************************************************************************"
    echo "New commits - available - please update before building!"
    echo "***************************************************************************************"
    echo ""
    echo "use following:"
    echo ""
    echo "git reset --hard"
    echo "git pull"
    exit 1
fi
