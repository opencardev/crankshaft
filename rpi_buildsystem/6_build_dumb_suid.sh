#!/bin/bash

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# Switch to home directory
cd ../src/dumb_suid

# Create inside build folder
make clean
make

cd $HOME
