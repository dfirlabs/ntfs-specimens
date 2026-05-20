#!/bin/bash
#
# Script to generate NTFS test files
# Requires Linux with dd and mkntfs

source ./shared_linux.sh

assert_availability_binary dd
assert_availability_binary mkntfs
assert_availability_binary setfattr

set -e

VERSION=$( mkntfs -V | sed -n '2p' | sed 's/^mkntfs v\(\S*\) .*$/\1/' )

SPECIMENS_PATH="specimens/mkntfs-${VERSION}"

mkdir -p ${SPECIMENS_PATH}

MOUNT_POINT="/mnt/ntfs"

sudo mkdir -p ${MOUNT_POINT}

# Minimum NTFS volume size is 1 MiB.
DEFAULT_IMAGE_SIZE=$(( 4096 * 1024 ))

IMAGE_SIZE=${DEFAULT_IMAGE_SIZE}
SECTOR_SIZE=512

# Create a NTFS file system
IMAGE_FILE="${SPECIMENS_PATH}/ntfs.raw"

echo "Creating: NTFS"
dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE}

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT}

create_test_file_entries ${MOUNT_POINT}

sudo umount ${MOUNT_POINT}

echo "Creating: NTFS; without: ADS support (streams_interface=windows)"
IMAGE_FILE="${SPECIMENS_PATH}/ntfs_no_ads.raw"

dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE}

sudo mount -o loop,rw,compression ${IMAGE_FILE} ${MOUNT_POINT}

create_test_file_entries ${MOUNT_POINT}

sudo umount ${MOUNT_POINT}

for CLUSTER_SIZE in 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152
do
	for SECTOR_SIZE in 256 512 1024 2048 4096
	do
		# Note that mkntfs requires the cluster size to be greater or equal the sector size or
		# the cluster size less than or equal 4096 times the size of the sector size.
		if test ${CLUSTER_SIZE} -lt ${SECTOR_SIZE} || test ${CLUSTER_SIZE} -gt $(( ${SECTOR_SIZE} * 4096 ))
		then
			continue
		fi
		IMAGE_FILE="${SPECIMENS_PATH}/ntfs_cluster_${CLUSTER_SIZE}_sector_${SECTOR_SIZE}.raw"

		# Make sure the image has more than 32 cluster blocks
		IMAGE_SIZE=$(( ${CLUSTER_SIZE} * 48 ))

		if test ${IMAGE_SIZE} -lt ${DEFAULT_IMAGE_SIZE}
		then
			IMAGE_SIZE=${DEFAULT_IMAGE_SIZE}
		fi

		echo "Creating: NTFS; with: custer size: ${CLUSTER_SIZE} and sector size: ${SECTOR_SIZE}"
		dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null

		mkntfs -F -q -L "ntfs_test" -c ${CLUSTER_SIZE} -s ${SECTOR_SIZE} ${IMAGE_FILE}

		# NTFS3g does not support a cluster size of 256.
		if test ${CLUSTER_SIZE} -gt 256
		then
			sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT}

			create_test_file_entries ${MOUNT_POINT}

			sudo umount ${MOUNT_POINT}
		fi
	done
done

IMAGE_SIZE=${DEFAULT_IMAGE_SIZE}
IMAGE_FILE="${SPECIMENS_PATH}/ntfs_corrupted.raw"

echo "Creating: NTFS; with corrupted files"
dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE}

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT}

mkdir ${MOUNT_POINT}/compressed

setfattr -h -v 0x00080000 -n system.ntfs_attrib ${MOUNT_POINT}/compressed

cp LICENSE ${MOUNT_POINT}/compressed/lznt1_empty

# Make sure the lznt1 compressed data run is large enough to store lznt1.bin
cp LICENSE ${MOUNT_POINT}/compressed/lznt1_truncated
cat LICENSE >> ${MOUNT_POINT}/compressed/lznt1_truncated

sudo umount ${MOUNT_POINT}

# Make sure to unmount before making modifications to the data streams

# TODO: determine extent of lznt1_empty file and fill with 0-byte values
dd conv=notrunc if=/dev/zero of=${IMAGE_FILE} bs=4096 seek=$(( 0x000e9000 / 4096 )) count=$(( 12288 / 4096 ))

# TODO: determine extent of lznt1_truncated file and fill first 0x4000 bytes with lznt1.bin and the remainder with with 0-byte values
dd conv=notrunc if=/dev/zero of=${IMAGE_FILE} bs=4096 seek=$(( 0x000ec000 / 4096 )) count=$(( 20480 / 4096 ))
dd conv=notrunc if=lznt1.bin of=${IMAGE_FILE} bs=4096 seek=$(( 0x000ec000 / 4096 ))

exit ${EXIT_SUCCESS}
