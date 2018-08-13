#!/bin/bash -e

# place files from prebuilt repo to correct place for normal build process

# udev rules updates
cp -f $BASE_DIR/prebuilts/udev/51-android.rules files/etc/udev/rules.d/51-android.master

DEST=files/etc/udev/rules.d/51-android.rules
if [ -f $DEST ]; then
    rm $DEST
fi
touch $DEST
# add master stuff
echo '' > $DEST
echo '# Skip storage devices' >> $DEST
echo 'KERNEL=="sd*", GOTO="SKIP_DEVICE"' >> $DEST
echo 'KERNEL=="sg*", GOTO="SKIP_DEVICE"' >> $DEST
echo 'SUBSYSTEM!="usb", GOTO="SKIP_DEVICE"' >> $DEST
cat files/etc/udev/rules.d/51-android.master >> $DEST
# Add action
sudo sed -i 's/GROUP="plugdev"$/GROUP="plugdev", RUN+="\/opt\/crankshaft\/usb_action.sh add '\'\$env\{ID_MODEL\}\'' '\''%E\{DEVNAME\}'\''"/' $DEST
# Add disconnect action
echo '' >> $DEST
echo '# Disconnect action' >> $DEST
echo 'SUBSYSTEM=="usb", ACTION=="remove", RUN+="/opt/crankshaft/usb_action.sh remove '\'\$env\{ID_MODEL\}\'' '\''%E{DEVNAME}'\''"' >> $DEST
# Add disconnect action
echo '' >> $DEST
echo '# Skip action' >> $DEST
echo 'LABEL="SKIP_DEVICE"' >> $DEST
echo '' >> $DEST

# csmt updates
cp -f $BASE_DIR/prebuilts/csmt/crankshaft files/usr/local/bin/crankshaft
chmod 777 files/usr/local/bin/crankshaft

# gpio2kbd updates
cp -f $BASE_DIR/prebuilts/gpio2kbd/gpio2kbd files/opt/crankshaft/gpio2kbd
chmod 777 files/opt/crankshaft/gpio2kbd

# openauto updates
cp -f $BASE_DIR/prebuilts/openauto/autoapp files/usr/local/bin/autoapp
cp -f $BASE_DIR/prebuilts/openauto/autoapp_helper files/usr/local/bin/autoapp_helper
cp -f $BASE_DIR/prebuilts/openauto/btservice files/usr/local/bin/btservice
cp -f $BASE_DIR/prebuilts/openauto/libaasdk.so files/usr/local/lib/libaasdk.so
cp -f $BASE_DIR/prebuilts/openauto/libaasdk_proto.so files/usr/local/lib/libaasdk_proto.so
# checksum files
cp -f $BASE_DIR/prebuilts/openauto/autoapp.md5 files/usr/local/bin/autoapp.md5
cp -f $BASE_DIR/prebuilts/openauto/autoapp_helper.md5 files/usr/local/bin/autoapp_helper.md5
cp -f $BASE_DIR/prebuilts/openauto/btservice.md5 files/usr/local/bin/btservice.md5
cp -f $BASE_DIR/prebuilts/openauto/libaasdk.so.md5 files/usr/local/lib/libaasdk.so.md5
cp -f $BASE_DIR/prebuilts/openauto/libaasdk_proto.so.md5 files/usr/local/lib/libaasdk_proto.so.md5

chmod 777 files/usr/local/bin/autoapp
chmod 777 files/usr/local/bin/autoapp_helper
chmod 777 files/usr/local/bin/btservice
chmod 666 files/usr/local/lib/libaasdk.so
chmod 666 files/usr/local/lib/libaasdk_proto.so

chmod 644 files/usr/local/bin/autoapp.md5
chmod 644 files/usr/local/bin/autoapp_helper.md5
chmod 644 files/usr/local/bin/btservice.md5
chmod 644 files/usr/local/lib/libaasdk.so.md5
chmod 644 files/usr/local/lib/libaasdk_proto.so.md5

# qt5
cp -f $BASE_DIR/prebuilts/qt5/Qt_5101_OpenGLES2.tar.xz files/qt5/Qt5_OpenGLES2.tar.xz
cp -f $BASE_DIR/prebuilts/qt5/Qt_5101_libs_OpenGLES2.tar.xz files/qt5/Qt5_libs_OpenGLES2.tar.xz