#!/bin/bash

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# Copy qt5
if [ ! -e ../prebuilt/libQt5_OpenGLES2.tar.xz ]; then
    cp qt5_build/libQt5_OpenGLES2.tar.xz ../prebuilt
fi

# Copy aasdk so's
if [ ! -e ../rootfs/usr/local/lib/libaasdk.so ]; then
    cp aasdk/lib/libaasdk.so ../crankshaft/rootfs/usr/local/lib
fi

if [ ! -e ../rootfs/usr/local/lib/libaasdk_proto.so ]; then
    cp aasdk/lib/libaasdk_proto.so ../crankshaft/rootfs/usr/local/lib
fi

# Copy openauto
if [ ! -e ../rootfs/usr/local/bin/autoapp ]; then
    cp openauto/bin/autoapp ../crankshaft/rootfs/usr/local/bin
fi

if [ ! -e ../rootfs/usr/local/bin/btservice ]; then
    cp openauto/bin/btservice ../crankshaft/rootfs/usr/local/bin
fi

# Copy dumb_suid
if [ ! -e ../rootfs/opt/crankshaft/dumb_suid ]; then
    cp ../src/dumb_suid/dumb_suid ../crankshaft/rootfs/opt/crankshaft
fi

# Copy gpio2kbd
if [ ! -e ../rootfs/opt/crankshaft/gpio2kbd ]; then
    cp gpio2kbd/gpio2kbd ../crankshaft/rootfs/opt/crankshaft
fi

cd $HOME
