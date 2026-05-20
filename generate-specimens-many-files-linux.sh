#!/bin/bash
#
# Script to generate NTFS test files, that contain many files
# Requires Linux with dd and mkntfs

source ./shared_linux.sh

assert_availability_binary dd
assert_availability_binary mkntfs

set -e

VERSION=$( mkntfs -V | sed -n '2p' | sed 's/^mkntfs v\(\S*\) .*$/\1/' )

SPECIMENS_PATH="specimens/mkntfs-${VERSION}-many-files"

mkdir -p ${SPECIMENS_PATH}

MOUNT_POINT="/mnt/ntfs"

sudo mkdir -p ${MOUNT_POINT}

SECTOR_SIZE=512

# 1000000 is disabled for now since it creates a 2 GiB test image and a while to
# generate causing sudo to time out.
for NUMBER_OF_FILES in 100 1000 10000 100000
do
	if test ${NUMBER_OF_FILES} -eq 10000000
	then
		# TODO: this is a guestimate
		IMAGE_SIZE=$(( 8192 * 4096 * 1024 ))

	elif test ${NUMBER_OF_FILES} -eq 1000000
	then
		IMAGE_SIZE=$(( 512 * 4096 * 1024 ))

	elif test ${NUMBER_OF_FILES} -eq 100000
	then
		IMAGE_SIZE=$(( 32 * 4096 * 1024 ))

	elif test ${NUMBER_OF_FILES} -eq 10000
	then
		IMAGE_SIZE=$(( 4 * 4096 * 1024 ))
	else
		# Minimum NTFS volume size is 1 MiB.
		IMAGE_SIZE=$(( 4096 * 1024 ))
	fi

	IMAGE_FILE="${SPECIMENS_PATH}/ntfs_${NUMBER_OF_FILES}_files.raw"

	echo "Creating: NTFS; with: ${NUMBER_OF_FILES} files"
	dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null

	mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE}

	sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT}

	create_test_file_entries ${MOUNT_POINT}

	# Create additional files
	for NUMBER in `seq 3 ${NUMBER_OF_FILES}`
	do
		if test $(( ${NUMBER} % 2 )) -eq 0
		then
			touch ${MOUNT_POINT}/testdir1/TestFile${NUMBER}
		else
			touch ${MOUNT_POINT}/testdir1/testfile${NUMBER}
		fi
	done

	sudo umount ${MOUNT_POINT}
done

exit ${EXIT_SUCCESS}
