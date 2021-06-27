#!/bin/bash

UUU=./uuu
FASTBOOT=./fastboot
MODE=none
UBOOT=`ls -t *.bin | head -1`

if [ ! -f *raw.img ];then
	echo "raw image not exist, unzip raw image"
	ZIPIMAGE=`ls -t *raw.img.zip | head -1`
	unzip $ZIPIMAGE
fi

IMAGE=`ls -t *raw.img | head -1`

function check_device_mode()
{
	FB=$($UUU -lsusb | grep FB)
	if [[ -n $FB ]]; then
		MODE=fastboot
	fi

	SDP=$($UUU -lsusb | grep SDP)
	if [[ -n $SDP ]]; then
		MODE=serial
	fi
}

check_device_mode
echo device_mode = $MODE

if [ $MODE == "none" ]; then
	echo Device not in download mode
	echo Maybe device not connect with PC or device in normal mode.
	exit
fi

echo "sudo $UUU -b emmc_all $UBBOT $IMAGE"

sudo $UUU -b emmc_all $UBOOT $IMAGE
echo Rebooting device
sudo $UUU FB: ucmd reset > null
echo Reboot successfully
sudo $FASTBOOT reboot

exit
