#
# (C) Copyright 2014 Hardkernel Co,.Ltd
#
#!/bin/sh


TARGET=./target
TARGETD=$TARGET/LibreELEC-Odroid_C1.arm-7.0.2
BOOTLOADER=$TARGETD/3rdparty/bootloader

BL1=$BOOTLOADER/bl1
UBOOT=$BOOTLOADER/u-boot

if [ -z $1 ]; then
        echo "usage ./sd_fusing.sh <SD card reader's device file>"
        exit 0
fi

if [ ! -f $BL1 ]; then
        echo "Error: $BL1 is not exist."
        exit 0
fi

if [ ! -f $UBOOT ]; then
        echo "Error: $UBOOT is not exist."
        exit 0
fi

sudo rm -R $TARGETD
sudo umount "$1""1"
sudo umount "$1""2"
tar -xvf $TARGETD.tar -C $TARGET

sudo dd if=$BL1 of=$1 bs=1 count=442
sudo dd if=$BL1 of=$1 bs=512 skip=1 seek=1
sudo dd if=$UBOOT of=$1 bs=512 seek=64
sync
sudo eject $1
echo FINISH
