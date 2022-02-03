#!/bin/bash -e

# qt5 from prebuilts
cat $BASE_DIR/prebuilts/qt5/Qt_5151_armv7l_OpenGLES2.tar.xz* > files/qt5/Qt5_OpenGLES2.tar.xz

#qt5
tar -xf files/qt5/Qt5_OpenGLES2.tar.xz -C ${ROOTFS_DIR}/