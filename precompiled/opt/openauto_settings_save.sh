#!/bin/bash

mount -o remount,rw /
cp /tmp/openauto.ini ~/.openauto_saved.ini
sync
mount -o remount,ro /

