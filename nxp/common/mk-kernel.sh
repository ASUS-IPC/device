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
KERNEL_DTB=`ls $TOP_DIR/linux-imx/arch/arm64/boot/dts/freescale | grep "fsl-imx8mq" | grep dtb`
IMX_M4_DEMOS="$TOP_DIR/device/nxp/common/${NXP_SOC}/imx-m4-demos"

#IMAGES=$TOP_DIR/Image-${NXP_TARGET_PRODUCT}-debian
[ ! -d ${IMAGES} ] && mkdir ${IMAGES}


function build_kernel(){
	echo "============Start build kernel============"
	echo "TARGET_ARCH          = $NXP_ARCH"
	echo "TARGET_KERNEL_CONFIG = $NXP_KERNEL_DEFCONFIG"
	echo "=========================================="
	cd $TOP_DIR/linux-imx
	export ARCH=$NXP_ARCH
	export CROSS_COMPILE=$ARM64_CROSS_COMPILE
	make $NXP_KERNEL_DEFCONFIG
	make -j$NXP_JOBS
	if [ $? -eq 0 ]; then
		echo "====Build kernel ok!===="
	else
		echo "====Build kernel failed!===="
		exit 1
	fi

	rm -rf $TOP_DIR/debian/packages/${NXP_SOC}/linux-imx/
	
	make ARCH=$NXP_ARCH CROSS_COMPILE=$ARM64_CROSS_COMPILE modules -j$NXP_JOBS
	make ARCH=$NXP_ARCH CROSS_COMPILE=$ARM64_CROSS_COMPILE modules_install INSTALL_MOD_PATH=$TOP_DIR/debian/packages/${NXP_SOC}/linux-imx/modules
	if [ $? -eq 0 ]; then
		echo "====Build kernel modules ok!===="
	else
		echo "====Build kernel modules failed!===="
		exit 1
	fi
}

# Generate the boot image with the boot scripts and required Device Tree files
function create_boot() {
	if [ $(expr $BOOT_SPACE / 1024) -gt 512 ]; then
		FATSIZE="-F 32"
	fi

	rm -f ${IMAGES}/boot.img
	echo mkfs.vfat -n "${BOOTDD_VOLUME_ID}" -S 512 ${FATSIZE} -C ${IMAGES}/boot.img $BOOT_SPACE
	mkfs.vfat -n "${BOOTDD_VOLUME_ID}" -S 512 ${FATSIZE} -C ${IMAGES}/boot.img $BOOT_SPACE
	
	echo mcopy -i ${IMAGES}/boot.img -s ${KERNEL}/${KERNEL_BIN} ::Image
	mcopy -i ${IMAGES}/boot.img -s ${KERNEL}/${KERNEL_BIN} ::Image

	# Copy device tree file
	for DTB in ${KERNEL_DTB}; do
		echo mcopy -i ${IMAGES}/boot.img -s ${KERNEL}/dts/freescale/${DTB} ::${DTB}
		mcopy -i ${IMAGES}/boot.img -s ${KERNEL}/dts/freescale/${DTB} ::${DTB}
	done

	# Copy extlinux.conf to images that have U-Boot Extlinux support.
	if [ "${UBOOT_EXTLINUX}" = "1" ]; then
		mmd -i ${IMAGES}/boot.img ::/extlinux
		mcopy -i ${IMAGES}/boot.img -s ${DEPLOY_DIR_IMAGE}/extlinux.conf ::/extlinux/extlinux.conf
	fi

	# Copy additional files to boot partition: such as m4 images and firmwares
	IMX_M4_DEMOS_LIST=`ls $IMX_M4_DEMOS`
	for IMAGE_FILE in $IMX_M4_DEMOS_LIST; do
		echo "mcopy -i ${IMAGES}/boot.img -s ${IMX_M4_DEMOS}/${IMAGE_FILE} ::/${IMAGE_FILE}"
		mcopy -i ${IMAGES}/boot.img -s ${IMX_M4_DEMOS}/${IMAGE_FILE} ::/${IMAGE_FILE}
	done

    # add tee to boot image
#    if ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'true', 'false', d)}; then
#        for UTEE_FILE_PATH in `find ${DEPLOY_DIR_IMAGE} -maxdepth 1 -type f -name 'uTee-*' -print -quit`; do
#            UTEE_FILE=`basename ${UTEE_FILE_PATH}`
#	    echo "mcopy -i ${IMAGES}/boot.img -s ${DEPLOY_DIR_IMAGE}/${UTEE_FILE} ::/${UTEE_FILE}"
#            mcopy -i ${IMAGES}/boot.img -s ${DEPLOY_DIR_IMAGE}/${UTEE_FILE} ::/${UTEE_FILE}
#        done
#    fi

}
echo $BOOTDD_VOLUME_ID
build_kernel
create_boot
