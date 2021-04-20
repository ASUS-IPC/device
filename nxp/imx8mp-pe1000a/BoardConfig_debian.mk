#!/bin/bash
# Target product
export NXP_TARGET_PRODUCT=imx8mp-pe1000a
# Target hostname
export NXP_HOSTNAME=PE1000A
# Target SoC
export NXP_SOC=imx8mp
# Target arch
export NXP_ARCH=arm64
# Uboot defconfig
export NXP_UBOOT_DEFCONFIG=imx8mp_pe1000a_defconfig
# Kernel defconfig
export NXP_KERNEL_DEFCONFIG=pe1000a_defconfig
# Kernel dts
export NXP_KERNEL_DTS=fsl-imx8mp-pe1000a
# Build jobs
export NXP_JOBS=12
