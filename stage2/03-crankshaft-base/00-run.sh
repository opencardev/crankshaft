#!/bin/bash -e

# udev rules updates
wget --no-check-certificate -O files/etc/udev/rules.d/51-android.update https://raw.githubusercontent.com/opencardev/prebuilts/master/udev/51-android.rules
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
cat files/etc/udev/rules.d/51-android.update >> $DEST
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
cp -f files/etc/udev/rules.d/51-android.update  files/etc/udev/rules.d/51-android.master
rm files/etc/udev/rules.d/51-android.update

# csmt updates
wget --no-check-certificate -O files/usr/local/bin/crankshaft.update https://raw.githubusercontent.com/opencardev/prebuilts/master/csmt/crankshaft
cp -f files/usr/local/bin/crankshaft.update files/usr/local/bin/crankshaft
chmod 777 files/usr/local/bin/crankshaft
rm files/usr/local/bin/crankshaft.update

# gpio2kbd updates
wget --no-check-certificate -O files/opt/crankshaft/gpio2kbd.update https://raw.githubusercontent.com/opencardev/prebuilts/master/gpio2kbd/gpio2kbd
cp -f files/opt/crankshaft/gpio2kbd.update files/opt/crankshaft/gpio2kbd
chmod 777 files/opt/crankshaft/gpio2kbd
rm files/opt/crankshaft/gpio2kbd.update
