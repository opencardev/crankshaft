#!/bin/bash

while true; do
    run=$(ps -ax | grep /usr/bin/kodi | grep -v grep | tail -n1 | sed 's/ //g')
    if [ ! -z $run ]; then
	touch /tmp/kodi_running
    else
	sudo rm -f /tmp/kodi_running > /dev/null 2>&1
    fi
    sleep 1
done

exit 0
