#!/bin/bash

CMD=`realpath $0`
COMMON_DIR=`dirname $CMD`
TOP_DIR=$(realpath $COMMON_DIR/../../..)
ARM64_CROSS_COMPILE=/usr/bin/aarch64-linux-gnu-
IMAGES=$TOP_DIR/Image-${NXP_TARGET_PRODUCT}-debian

function build_uboot()
{
	echo "============Start build kernel============"
	echo "TARGET_ARCH          =$NXP_ARCH"
	echo "TARGET_UBOOT_CONFIG =$NXP_UBOOT_DEFCONFIG"
	echo "=========================================="
	export ARCH=$NXP_ARCH
	export CROSS_COMPILE=$ARM64_CROSS_COMPILE
	cd $TOP_DIR/uboot-imx
	make $NXP_UBOOT_DEFCONFIG
	make -j$NXP_JOBS
}

# #ARM Trusted Firmware
function build_atf()
{
	cd $TOP_DIR/imx-atf
	make PLAT=${NXP_SOC} bl31
}

function build_bootloader()
{
	cd $TOP_DIR/imx-mkimage
	cp $TOP_DIR/uboot-imx/tools/mkimage iMX8M/mkimage_uboot
	cp $TOP_DIR/uboot-imx/spl/u-boot-spl.bin iMX8M/
	cp $TOP_DIR/uboot-imx/u-boot-nodtb.bin iMX8M/
	cp $TOP_DIR/uboot-imx/arch/arm/dts/${NXP_KERNEL_DTS}.dtb iMX8M/
	cp $TOP_DIR/imx-atf/build/${NXP_SOC}/release/bl31.bin iMX8M/
	cp $COMMON_DIR/${NXP_SOC}/firmware-imx-*/firmware/ddr/synopsys/lpddr4_pmu_train_* iMX8M/
	cp $COMMON_DIR/${NXP_SOC}/firmware-imx-*/firmware/hdmi/cadence/signed_hdmi_imx8m.bin iMX8M/
	if [ "${NXP_SOC}" == "imx8mq" ]; then
		make SOC=iMX8M DTB=${NXP_KERNEL_DTS}.dtb flash_evk
	elif [ "${NXP_SOC}" == "imx8mm" ]; then
		make SOC=iMX8MM DTB=${NXP_KERNEL_DTS}.dtb  flash_evk
	fi
	cp iMX8M/flash.bin $IMAGES
}

build_uboot
build_atf
build_bootloader
