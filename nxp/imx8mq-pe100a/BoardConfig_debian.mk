#!/bin/bash
# Target product
export NXP_TARGET_PRODUCT=imx8mq-pe100a
# Target hostname
export NXP_HOSTNAME=PE100A
# Target SoC
export NXP_SOC=imx8mq
# Target arch
export NXP_ARCH=arm64
# Uboot defconfig
export NXP_UBOOT_DEFCONFIG=imx8mq_pe100a_defconfig
# Kernel defconfig
export NXP_KERNEL_DEFCONFIG=pe100a_defconfig
# Kernel dts
export NXP_KERNEL_DTS=fsl-imx8mq-pe100a
# Build jobs
export NXP_JOBS=12
