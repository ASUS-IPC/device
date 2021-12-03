#!/bin/bash
# Target product
export NXP_TARGET_PRODUCT=imx8mq-im-a
# Target hostname
export NXP_HOSTNAME=imx8p-im-a
# Target SoC
export NXP_SOC=imx8mq
# Target arch
export NXP_ARCH=arm64
# Uboot defconfig
export NXP_UBOOT_DEFCONFIG=imx8mq_ima_defconfig
# Kernel defconfig
export NXP_KERNEL_DEFCONFIG=ima_defconfig
# Kernel dts
export NXP_KERNEL_DTS=fsl-imx8mq-ima
# Build jobs
export NXP_JOBS=12
# Board DDR size
export NXP_DDR_SIZE=4G
