#!/bin/bash

sleep 60
/usr/local/bin/crankshaft filesystem boot unlock
/usr/bin/systemd-analyze plot > /boot/crankshaft/startsequence.svg
/usr/local/bin/crankshaft filesystem boot lock
