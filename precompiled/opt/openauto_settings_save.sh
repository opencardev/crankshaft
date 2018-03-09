#!/bin/bash

mount -o remount,rw /
cp ~/.config/openauto.ini ~/.openauto_saved.ini
sync
mount -o remount,ro /

