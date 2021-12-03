#!/bin/bash
# Target product
export NXP_TARGET_PRODUCT=imx8mq-pv100a2g
# Target hostname
export NXP_HOSTNAME=PV100A
# Target SoC
export NXP_SOC=imx8mq
# Target arch
export NXP_ARCH=arm64
# Uboot defconfig
export NXP_UBOOT_DEFCONFIG=imx8mq_pv100a_2g_defconfig
# Kernel defconfig
export NXP_KERNEL_DEFCONFIG=pv100a_defconfig
# Kernel dts
export NXP_KERNEL_DTS=fsl-imx8mq-pv100a
# Build jobs
export NXP_JOBS=12
# Board DDR size
export NXP_DDR_SIZE=2G
