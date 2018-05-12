#!/bin/bash

# adapted from ezpi4me - Raspberry Pi ME image creation script
# Written by Huan Truong <htruong@tnhh.net>, 2018
# This script is licensed under GNU Public License v3

IMAGE_FILE=raspbian-stretch-lite.zip
TODAY_EXT=$(date +"%Y-%m-%d-%H-%M")
BUILD_ID=$(hexdump -n 4 -e '4/4 "%X" 1 "\n"' /dev/random)
IMAGE_FILE_CUSTOMIZED=${IMAGE:-"crankshaft-${TODAY_EXT}-${BUILD_ID}.img"}
IMAGE_URL=https://downloads.raspberrypi.org/raspbian_lite_latest
TEMP_CHROOT_DIR=/mnt/raspbian-temp
DROP_IN=${DROP_IN:-0}
CUSTOM_SCRIPT=${CUSTOM_SCRIPT:-""}

clear
echo "###########################################################################"
echo ""
echo "                  Welcome to the Crankshaft build script!"
echo ""
echo "###########################################################################"

#########################################################
# Support functions
#########################################################

bail_and_cleanup() {
    kpartx -d $1
    # rm $2
}

check_command_ok() {
    if ! [ -x "$(command -v $1)" ]; then
        echo "###########################################################################"
        echo ""
        echo "Error: $1 is not installed. Please install it." >&2
        echo ""
        echo "###########################################################################"
        exit 1
    fi
}

check_root() {
    # make sure we're root
    if [ "$EUID" -ne 0 ]; then
        echo "###########################################################################"
        echo ""
        echo "Please run this script as using sudo/as root, otherwise it can't continue. "
        echo ""
        echo "###########################################################################"

        exit
    fi
}

check_dependencies() {
    check_command_ok kpartx
    # check_command_ok parted
    check_command_ok qemu-arm-static
    check_command_ok chroot
    check_command_ok pv
    check_command_ok zipinfo
    check_command_ok zerofree
}

get_unzip_image() {
    #get raspberry image
    if [ -f ${IMAGE_FILE} ]; then
        #check remote filze size
        remotesize=`wget https://downloads.raspberrypi.org/raspbian_lite_latest --spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}'`
        localsize=`wc -c ${IMAGE_FILE} | awk '{print $1}'`
        # Failsafe - if string length of remote size is to short try again (sometimes happens caused by delayed response)
        if [ ${#remotesize} != ${#localsize} ]; then
            remotesize=`wget https://downloads.raspberrypi.org/raspbian_lite_latest --spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}'`
        fi

        if [ "$remotesize" = "$localsize" ]; then
            echo "---------------------------------------------------------------------------"
            echo "Image file ${IMAGE_FILE} is already the same, skipping download."
            echo "It will be re-downloaded if remote file has changed."
            echo "---------------------------------------------------------------------------"
        else
            #re-download cause filesize has changed
            echo "---------------------------------------------------------------------------"
            echo "Downloading new version of raspbian image from server..."
            wget -q --show-progress -O${IMAGE_FILE} ${IMAGE_URL}
            echo "---------------------------------------------------------------------------"
        fi
    else
        echo "---------------------------------------------------------------------------"
        echo "Downloading raspbian image from server..."
        wget -q --show-progress -O${IMAGE_FILE} ${IMAGE_URL}
        echo "---------------------------------------------------------------------------"
    fi

    IMAGE_FILE_UNZIPPED=`zipinfo -1 ${IMAGE_FILE}`
    IMAGE_FILE_UNZIPPED_SIZE=`zipinfo -l ${IMAGE_FILE} | tail -1 | xargs | cut -d' ' -f3`

    if ! [ -f ${IMAGE_FILE_UNZIPPED} ]; then
        echo "---------------------------------------------------------------------------"
        echo "Unpacking raspbian image..."
        echo "---------------------------------------------------------------------------"
        unzip -o -p ${IMAGE_FILE} | pv -p -s ${IMAGE_FILE_UNZIPPED_SIZE} -w 80 > ${IMAGE_FILE_UNZIPPED}
    fi

    if ! [ -f ${IMAGE_FILE_CUSTOMIZED} ]; then
        echo "---------------------------------------------------------------------------"
        echo "Copying a big file..."
        echo "---------------------------------------------------------------------------"
        cp ${IMAGE_FILE_UNZIPPED} ${IMAGE_FILE_CUSTOMIZED}
    else
        echo "---------------------------------------------------------------------------"
        echo "Skipping creation of ${IMAGE_FILE_CUSTOMIZED}, it's already there. To re-create, delete it."
        echo "---------------------------------------------------------------------------"
    fi
}

resize_raw_image() {
    IMAGE_SIZE_RAW=$(wc -c < "${IMAGE_FILE_UNZIPPED}")
    IMAGE_SIZE_ACTUAL=$(wc -c < "${IMAGE_FILE_CUSTOMIZED}")
    IMAGE_ROOTPART_START=$(parted ${IMAGE_FILE_UNZIPPED} unit s print -sm | tail -1 | cut -d: -f2 | sed 's/s//')
    if [ ${IMAGE_SIZE_ACTUAL} -gt ${IMAGE_SIZE_RAW} ]; then
        echo "---------------------------------------------------------------------------"
        echo "Image seems already resized, or something is wrong."
        echo "If the image doesn't work, try removing the .img and try again."
        echo "---------------------------------------------------------------------------"
        return
    fi
    echo "---------------------------------------------------------------------------"
    echo "Resizing image..."
    echo "---------------------------------------------------------------------------"

    #resize image
    dd if=/dev/zero bs=1M count=512 >> ${IMAGE_FILE_CUSTOMIZED}

    PART_NUM=2

    fdisk ${IMAGE_FILE_CUSTOMIZED} <<EOF
p
d
$PART_NUM
n
p
$PART_NUM
$IMAGE_ROOTPART_START

p
w
EOF

}

set_up_loopdevs() {
    # mount the resized partition
    kpartx -v -a ${IMAGE_FILE_CUSTOMIZED} | tee /tmp/kpartx-output.txt
    LOOPPARTSID=`cat /tmp/kpartx-output.txt | head -n1 | sed 's/add map //' | cut -f1 -d' ' | sed 's/p1$//'`

    #echo "-- LoopFS setup --\n${LOOPPARTSRET}"
    echo "---------------------------------------------------------------------------"
    echo "The loop device is ${LOOPPARTSID}"
    echo "---------------------------------------------------------------------------"
    sync
    sleep 2

    # it should have two partitions at /dev/mapper
    if ! [ -L /dev/mapper/${LOOPPARTSID}p1 ]; then
        echo "###########################################################################"
        echo "                                                                           "
        echo "Couldn't find the loopdev partitions at /dev/mapper/${LOOPPARTSID}p1!"
        echo "                                                                           "
        echo "###########################################################################"
        bail_and_cleanup /dev/${LOOPPARTSID} ${IMAGE_FILE_CUSTOMIZED}
        exit 1
    fi

    echo "---------------------------------------------------------------------------"
    echo "Found the loopdev partitions at /dev/mapper/${LOOPPARTSID}!"
    echo "---------------------------------------------------------------------------"
    LOOPDEVPARTS=/dev/mapper/${LOOPPARTSID}

    echo "---------------------------------------------------------------------------"
    echo "Check rootfs before resize..."
    echo "---------------------------------------------------------------------------"
    e2fsck -f ${LOOPDEVPARTS}p2

    echo "---------------------------------------------------------------------------"
    echo "Resize rootfs..."
    echo "---------------------------------------------------------------------------"
    resize2fs -p ${LOOPDEVPARTS}p2

    echo "---------------------------------------------------------------------------"
    echo "Check rootfs afer resize..."
    echo "---------------------------------------------------------------------------"
    e2fsck -f ${LOOPDEVPARTS}p2

    mount_chroot_dirs ${LOOPDEVPARTS} ${LOOPPARTSID}

    # ld.so.preload fix
    sed -i 's/^/#CHROOT /g' ${TEMP_CHROOT_DIR}/etc/ld.so.preload

    # copy qemu binary
    cp `which qemu-arm-static` ${TEMP_CHROOT_DIR}/usr/bin/

    if [[ ${DROP_IN} -ne 0 ]]; then

        echo "---------------------------------------------------------------------------"
        echo -e "Dropping you in the chroot shell."
        echo "---------------------------------------------------------------------------"
        chroot ${TEMP_CHROOT_DIR} /bin/bash

    else 

        if [[ -n "${CUSTOM_SCRIPT}" ]]; then

            # eval the custom script

            eval ${CUSTOM_SCRIPT}

        else

            # make the image

            # extract libQt5
            echo "---------------------------------------------------------------------------"
            echo "Unpacking qt5 libraries..."
            echo "---------------------------------------------------------------------------"
            pv -p  -w 80 prebuilt/libQt5_OpenGLES2.tar.xz | tar -xf - -C ${TEMP_CHROOT_DIR}/

            # copy rest of CS stuff to the root home directory
            echo "---------------------------------------------------------------------------"
            echo "Copy crankshaft files to root..."
            echo "---------------------------------------------------------------------------"
            cp -a crankshaft/. ${TEMP_CHROOT_DIR}/root/

            sync
            sleep 1

            # phew, customize it
            chroot ${TEMP_CHROOT_DIR} /bin/bash /root/scripts/customize-image-pi.sh

            chroot ${TEMP_CHROOT_DIR} /bin/bash /root/scripts/read-only-fs.sh

        fi

    fi
    # undo ld.so.preload fix
    sed -i 's/^#CHROOT //g' ${TEMP_CHROOT_DIR}/etc/ld.so.preload

    umount_chroot_dirs

    zerofree ${LOOPDEVPARTS}p2

    umount_loop_dev /dev/${LOOPPARTSID}

    echo "###########################################################################"
    echo "                                                                           "
    echo "If you reach here, it means the image is ready. :)"
    echo "                                                                           "
    echo "###########################################################################"
}


mount_chroot_dirs() {
    echo "---------------------------------------------------------------------------"
    echo "Mounting CHROOT directories"
    echo "---------------------------------------------------------------------------"
    mkdir -p ${TEMP_CHROOT_DIR}

    mount -o rw ${1}p2 ${TEMP_CHROOT_DIR}
    mount -o rw ${1}p1 ${TEMP_CHROOT_DIR}/boot

    # mount binds
    mount --bind /dev ${TEMP_CHROOT_DIR}/dev/
    mount --bind /sys ${TEMP_CHROOT_DIR}/sys/
    mount --bind /proc ${TEMP_CHROOT_DIR}/proc/
    mount --bind /dev/pts ${TEMP_CHROOT_DIR}/dev/pts

    if  ! [ -f ${TEMP_CHROOT_DIR}/etc/ld.so.preload ]; then
        echo "###########################################################################"
        echo "                                                                           "
        echo "I didn't see ${TEMP_CHROOT_DIR}/etc/ folder. Bailing!"
        echo "                                                                           "
        echo "###########################################################################"
        umount_chroot_dirs
        umount_loop_dev $2
        exit 1
    fi

}

umount_chroot_dirs() {
    echo "---------------------------------------------------------------------------"
    echo "Unmount chroot dirs..."
    echo "---------------------------------------------------------------------------"
    sync
    umount ${TEMP_CHROOT_DIR}/{dev/pts,dev,sys,proc,boot,}
}

umount_loop_dev() {
    echo "---------------------------------------------------------------------------"
    echo "Unmount loop devices..."
    echo "---------------------------------------------------------------------------"
    loopdev=`echo $1 | cut -d"/" -f3`
    dmsetup remove -f $loopdev"p1"
    dmsetup remove -f $loopdev"p2"
    kpartx -d $1
}

#########################################################

check_dependencies
check_root
get_unzip_image
resize_raw_image
set_up_loopdevs
