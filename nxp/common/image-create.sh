#!/bin/bash -e

CMD=`realpath $0`
COMMON_DIR=`dirname $CMD`
TOP_DIR=$(realpath $COMMON_DIR/../../..)

# Partition table 
# size@offset(layout) [in KiB]
#partition_layout="65536@8192(boot),8192@73728(misc),4194304@81920(rootfs)"
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
partition_layout="${BOOT_SPACE}@${IMAGE_ROOTFS_ALIGNMENT}(boot),${MISC_SPACE}@$((BOOT_SPACE+IMAGE_ROOTFS_ALIGNMENT))(misc),${ROOTFS_SIZE}@$((MISC_SPACE+BOOT_SPACE+IMAGE_ROOTFS_ALIGNMENT))(rootfs)"
echo partition_layout=$partition_layout

# U-boot
IMX_BOOT_SEEK=33
UBOOT="flash.bin"

IMAGES=$TOP_DIR/Image-${NXP_TARGET_PRODUCT}-debian
SDBOOTIMG="${IMAGES}/${NXP_HOSTNAME}-debian-raw.img"

[ ! -d ${IMAGES} ] && mkdir ${IMAGES}

# Parsing partition layout
function parse_parameter
{
	local regex="[[:xdigit:]]*@[[:xdigit:]]+\([[:alpha:]]+"

	PARTITIONS=($(echo $1 | egrep -o "${regex}" | sed -r 's/\(/@/g'))

	for p in ${PARTITIONS[@]}; do
		l=$(echo $p | cut -d'@' -f1)
		SIZES=(${SIZES[@]} $l)

		l=$(echo $p | cut -d'@' -f2)
		OFFSETS=(${OFFSETS[@]} $l)

		l=$(echo $p | cut -d'@' -f3)
		LABELS=(${LABELS[@]} $l)
	done
}

function createIMG
{
	local last_image_size
	local last_offset

	for i in ${!LABELS[@]}; do
		echo label ${LABELS[$i]} offset ${OFFSETS[$i]} size ${SIZES[$i]}
		last_image_size=${SIZES[$i]}
		last_offset=${OFFSETS[$i]}
	done
	GPT_IMAGE_SIZE=$(expr $last_offset + $last_image_size + 8192)
	dd if=/dev/zero of=${SDBOOTIMG} bs=1K count=0 seek=$GPT_IMAGE_SIZE

	
	local ROOTFS=
	
	parted -s ${SDBOOTIMG} mklabel gpt
	for i in ${!LABELS[@]}; do
		local offset=${OFFSETS[$i]}
		local label=${LABELS[$i]}
		local size=${SIZES[$i]}
		echo "Create partition:$label at $offset with size $size"
		local end=$(($size + $offset))
		echo label $label end $end
		echo parted -s ${SDBOOTIMG} unit KiB mkpart $label $((${offset})) $((${end}))
		parted -s ${SDBOOTIMG} unit KiB mkpart $label $((${offset})) $((${end}))
	done

	parted ${SDBOOTIMG} print
}

function downloadImages
{
	echo "Downloading images..."
	local DEVICE=${SDBOOTIMG}

	echo dd if=$IMAGES/${UBOOT} of=${DEVICE} conv=notrunc seek=${IMX_BOOT_SEEK} bs=1K
	dd if=$IMAGES/${UBOOT} of=${DEVICE} conv=notrunc seek=${IMX_BOOT_SEEK} bs=1K
	sleep 1
	for i in ${!LABELS[@]}; do
		local label=${LABELS[$i]}
		local index=$(($i + 1))
		echo "Copy $label image to ${DEVICE} offset $((${OFFSETS[$i]}))"
		if [ -f $IMAGES/${label}.img ]; then
			echo dd if=$IMAGES/${label}.img of=${DEVICE} conv=notrunc,fsync seek=$((${OFFSETS[$i]})) bs=1K
			dd if=$IMAGES/${label}.img of=${DEVICE} conv=notrunc,fsync seek=$((${OFFSETS[$i]})) bs=1K
		else
			echo "$label image not found, skipped"
			echo "dd if=/dev/zero of==${DEVICE} conv=notrunc,fsync seek=$((${OFFSETS[$i]})) bs=1K count=${SIZES[$i]}"
			dd if=/dev/zero of=${DEVICE} conv=notrunc,fsync seek=$((${OFFSETS[$i]})) bs=1K count=${SIZES[$i]}
		fi
	done

	sync && sync
}
 
parse_parameter $partition_layout

createIMG

downloadImages
