#!/bin/bash

CMD=`realpath $0`
COMMON_DIR=`dirname $CMD`
TOP_DIR=$(realpath $COMMON_DIR/../../..)

function build_uboot(){
	cd $COMMON_DIR
        IMAGES=$IMAGES ./mk-uboot.sh
}

function build_kernel(){
	cd $COMMON_DIR
	IMAGES=$IMAGES ./mk-kernel.sh
}

function build_kernel_header(){
	cd $COMMON_DIR
	IMAGES=$IMAGES ./mk-kernel-header.sh
}


function build_debian(){
	ROOTFS_IMG=$TOP_DIR/$IMAGES/rootfs.img
	rm -f $ROOTFS_IMG

	cd $TOP_DIR/debian
	if [ ! -e debian-*.tar.gz ]; then
		echo -e "\033[36m Run mk-base-debian.sh first \033[0m"
		RELEASE=buster ARCH=$NXP_ARCH ./mk-base-debian.sh
	fi

	VERSION_NUMBER=$VERSION_NUMBER VERSION=$VERSION ./mk-rootfs-buster.sh

	IMAGES=$IMAGES ./mk-image.sh
	cd ..
	if [ $? -eq 0 ]; then
		echo "====Build Debian ok!===="
	else
		echo "====Build Debian failed!===="
		exit 1
	fi
}

function build_ubuntu()
{
	ROOTFS_IMG=$TOP_DIR/$IMAGES/rootfs.img
	rm -f $ROOTFS_IMG

	cd $TOP_DIR/debian
	if [ ! -e ubuntu-*.tar.gz ]; then
		echo -e "\033[36m Run mk-base-ubuntu.sh first \033[0m"
		RELEASE="18.04" ARCH=$NXP_ARCH ./mk-base-ubuntu.sh
	fi

	VERSION_NUMBER=$VERSION_NUMBER VERSION=$VERSION ./mk-rootfs-ubuntu.sh

	IMAGES=$IMAGES ./mk-image.sh
	cd ..
	if [ $? -eq 0 ]; then
		echo "====Build Ubuntu ok!===="
	else
		echo "====Build Ubuntu failed!===="
		exit 1
	fi
}

function build_rootfs(){
	case "${OS:-debian}" in
		debian)
			build_debian
			;;
		ubuntu)
			build_ubuntu
			;;
	esac
}

function build_image(){
	cd $COMMON_DIR
	OS=${OS:-debian} IMAGES=$IMAGES ./image-create.sh
	cp -rf $COMMON_DIR/tools/flash_tool/* $IMAGES
}

function build_all(){
	build_uboot
	build_kernel
	build_rootfs
	build_image
}

function build_cleanall(){
	echo "clean uboot, kernel, rootfs"
	cd $TOP_DIR/uboot-imx && make distclean && cd -
	cd $TOP_DIR/imx-atf && make distclean && cd -
	cd $TOP_DIR/imx-mkimage && make clean && cd -
	cd $TOP_DIR/linux-imx && make distclean && cd -
	sudo rm -rf $TOP_DIR/debian/binary
}

#=========================
# build targets
#=========================
if [ ! $VERSION ]; then
    VERSION="debug"
fi
echo "VERSION: $VERSION"

if [ ! $VERSION_NUMBER ]; then
	VERSION_NUMBER="eng_by"_"$USER"_"$(date  +%Y%m%d%H%M_%Z)"
else
	VERSION_NUMBER="$VERSION_NUMBER"_"$(date  +%Y%m%d%H%M_%Z)"
	OFFICIAL=1
fi
echo "VERSION_NUMBER: $VERSION_NUMBER"
echo ""
echo "1. IMX8MP-IM-A"
echo "2. PE100A"
echo "3. PE100A_2G"
echo "4. PV100A"
echo "5. PV100A_2G"
echo "6. IMX8MQ_EVK"
read -p "Select build product: " TARGET_PRODUCT
if [ ! $TARGET_PRODUCT ]; then
    TARGET_PRODUCT="1"
fi

echo ""
echo "1. All Image"
echo "2. U-boot Image"
echo "3. Kernel Image"
echo "4. Rootfs Image"
echo "5. RAW Image"
echo "6. kernel header"
echo "7. Cleanall"
read -p "Select build type: " BUILD
if [ ! $BUILD ]; then
    BUILD="1"
fi

echo ""

case $TARGET_PRODUCT in
1) TARGET_PRODUCT=imx8mq-im-a
   PRODUCT_NAME=IMX8P-IM-A
   ;;
2) TARGET_PRODUCT=imx8mq-pe100a
   PRODUCT_NAME=PE100A
   ;;
3) TARGET_PRODUCT=imx8mq-pe100a2g
   PRODUCT_NAME=PE100A-2G
   ;;
4) TARGET_PRODUCT=imx8mq-pv100a
   PRODUCT_NAME=PV100A
   ;;
5) TARGET_PRODUCT=imx8mq-pv100a2g
   PRODUCT_NAME=PV100A-2G
   ;;
6) TARGET_PRODUCT=imx8mqevk
   PRODUCT_NAME=IMX8MQ-EVK
   ;;
esac

source $TOP_DIR/device/nxp/${TARGET_PRODUCT}/BoardConfig_debian.mk
source $TOP_DIR/device/nxp/${TARGET_PRODUCT}/Partition.mk

if [ $OFFICIAL ]; then
	IMAGES=$TOP_DIR/${PRODUCT_NAME}_${OS:-debian}_${VERSION_NUMBER}_${VERSION}
else
	IMAGES=$TOP_DIR/Image-${NXP_TARGET_PRODUCT}-${OS:-debian}
fi

case $BUILD in
1)	# all image
	build_all
	;;
2)	# U-boot
	build_uboot
	;;
3)	# Kernel
	build_kernel
	;;
4)	# rootfs
	build_rootfs
	;;
5)	# raw
	build_image
	;;
6)	# Kernel header
	build_kernel_header
	;;
7)	# cleanall
	build_cleanall
	;;
*)	echo "Wrong parameter"
	;;
esac
