#!/bin/bash

mount -o remount,rw /boot/

cp /tmp/openauto.ini /boot/crankshaft/openauto.ini

/opt/crankshaft/brightness.sh save

sync

mount -o remount,ro /

