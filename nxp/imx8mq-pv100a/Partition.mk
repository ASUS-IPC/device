#!/bin/bash

# Partition table 
# size@offset(layout) [in KiB]
# partition_layout="65536@8192(boot),8192@73728(misc),4194304@81920(rootfs)"
#            8MiB               64MiB        8MiB           ROOTFS_SIZE                    8MiB
# <-----------------------> <----------> <----------> <----------------------> <------------------------------>
#  ------------------------ ------------ ------------ ------------------------ -------------------------------
# | IMAGE_ROOTFS_ALIGNMENT | BOOT_SPACE | MISC_SPACE |      ROOTFS_SIZE       |     IMAGE_ROOTFS_ALIGNMENT    |
#  ------------------------ ------------ ------------------------ ---------------------------------------------
# ^                        ^            ^            ^                        ^                               ^
# |                        |            |            |                        |                               |
# 0                       8MB        8+64 MB     8+64+8 MB           8+64+8+ROOTFS_SIZE             8+64+8+ROOTFS_SIZE+8 MB
#
#	Number  Start   End     Size    File system  Name    Flags
#	 1      8389kB  75.5MB  67.1MB               boot
#	 2      75.5MB  83.9MB  8389kB               misc
#	 3      83.9MB  4379MB  4295MB               rootfs
#
export IMAGE_ROOTFS_ALIGNMENT=8192	# 8MB
export BOOT_SPACE=65536			# 64MB
export MISC_SPACE=8192			# 8MB
export ROOTFS_SIZE=3145728		# 3GB
export ROOTFSIMAGE_SIZE=3000		# 3000MB
