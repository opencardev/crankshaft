#!/bin/bash

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# Switch to home directory
cd $HOME

# clone git repo
git clone -b master https://github.com/htruong/gpio2kbd.git

# Create inside build folder
cd $HOME/gpio2kbd
make

cd $HOME
