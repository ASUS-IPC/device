#!/bin/bash

CMD=`realpath $0`
COMMON_DIR=`dirname $CMD`
TOP_DIR=$(realpath $COMMON_DIR/../../..)
ARM64_CROSS_COMPILE=$TOP_DIR/prebuilts/gcc/linux-x86/aarch64/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

# Boot image
# Boot partition volume id
BOOTDD_VOLUME_ID="Boot ${NXP_HOSTNAME}"
KERNEL="$TOP_DIR/linux-imx/arch/arm64/boot"
KERNEL_BIN="Image"
IMX_M4_DEMOS="$TOP_DIR/device/nxp/common/${NXP_SOC}/imx-m4-demos"

#IMAGES=$TOP_DIR/Image-${NXP_TARGET_PRODUCT}-debian
[ ! -d ${IMAGES} ] && mkdir ${IMAGES}


function build_kernel_header(){
	echo "============Start build kernel header============"
	echo "TARGET_ARCH          = $NXP_ARCH"
	echo "TARGET_KERNEL_CONFIG = $NXP_KERNEL_DEFCONFIG"
	echo "=========================================="
	cd $TOP_DIR/linux-imx
	export ARCH=$NXP_ARCH
	export CROSS_COMPILE=$ARM64_CROSS_COMPILE
        make clean &&  make mrproper &&  make distclean
	make $NXP_KERNEL_DEFCONFIG
	make deb-pkg -j24
	if [ $? -eq 0 ]; then
		echo "====Build kernel header ok!===="
	else
		echo "====Build kernel header failed!===="
		exit 1
	fi
}


echo $BOOTDD_VOLUME_ID
build_kernel_header
