#!/bin/bash

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# clone git repo
git clone -b master https://github.com/f1xpl/aasdk.git

# Clean build folder
sudo rm -rf $HOME/aasdk_build

# Create build folder
mkdir -p $HOME/aasdk_build

# Create inside build folder
cd $HOME/aasdk_build
cmake -DCMAKE_BUILD_TYPE=Release ../aasdk
make

cd $HOME
