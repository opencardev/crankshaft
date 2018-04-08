#!/bin/bash

/opt/crankshaft/filesystem.sh unlock_boot

cp /tmp/openauto.ini /boot/crankshaft/openauto.ini

/opt/crankshaft/brightness.sh save

/opt/crankshaft/filesystem.sh lock_boot