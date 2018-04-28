#!/bin/bash

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# Create inside build folder
cd /opt/vc/src/hello_pi/libs/ilclient
make clean
make

cd $HOME
