#!/bin/bash
#
# Script to generate NTFS test files
# Requires Linux with dd and mkntfs

EXIT_SUCCESS=0;
EXIT_FAILURE=1;

# Checks the availability of a binary and exits if not available.
#
# Arguments:
#   a string containing the name of the binary
#
assert_availability_binary()
{
	local BINARY=$1;

	which ${BINARY} > /dev/null 2>&1;
	if test $? -ne ${EXIT_SUCCESS};
	then
		echo "Missing binary: ${BINARY}";
		echo "";

		exit ${EXIT_FAILURE};
	fi
}

# Creates test file entries.
#
# Arguments:
#   a string containing the mount point of the image file
#
create_test_file_entries()
{
	MOUNT_POINT=$1;

	# Create an empty file
	touch ${MOUNT_POINT}/emptyfile

	# Create a directory
	mkdir ${MOUNT_POINT}/testdir1

	# Create a file with a non-resident MFT data attribute
	echo "My file" > ${MOUNT_POINT}/testdir1/testfile1

	# Create a file with a non-resident MFT data attribute
	cp LICENSE ${MOUNT_POINT}/testdir1/testfile2

	# Create a file with a long filename
	touch "${MOUNT_POINT}/My long, very long file name, so very long"

	# Create a hard link to a file
	ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/file_hardlink1

	# Create a symbolic link to a file
	ln -s ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/file_symboliclink1

	# Create a hard link to a directory
	# ln: hard link not allowed for directory

	# Create a symbolic link to a directory
	ln -s ${MOUNT_POINT}/testdir1 ${MOUNT_POINT}/directory_symboliclink1

	# Create a file with a control code in the filename
	touch `printf "${MOUNT_POINT}/control_cod\x03"`

	# Create a file with an UTF-8 NFC encoded filename
	touch `printf "${MOUNT_POINT}/nfc_t\xc3\xa9stfil\xc3\xa8"`

	# Create a file with an UTF-8 NFD encoded filename
	touch `printf "${MOUNT_POINT}/nfd_te\xcc\x81stfile\xcc\x80"`

	# Create a file with an UTF-8 NFD encoded filename
	touch `printf "${MOUNT_POINT}/nfd_\xc2\xbe"`

	# Create a file with an UTF-8 NFKD encoded filename
	touch `printf "${MOUNT_POINT}/nfkd_3\xe2\x81\x844"`

	# Create a file with a 2-byte UTF-16 character that will expand into 3-byte UTF-8 character
	touch `printf "${MOUNT_POINT}/funky\xe2\x98\x80name"`

	# Create a file with an alternate data stream (ADS) with content
	touch ${MOUNT_POINT}/file_ads1
	echo "My file ADS" > ${MOUNT_POINT}/file_ads1:myads

	# Create a file with an alternate data stream (ADS) with a control code in the ADS name
	# touch ${MOUNT_POINT}/file_ads2
	# touch `printf "${MOUNT_POINT}/file_ads2:\x05SummaryInformation"`

	# Create a directory with an alternate data stream (ADS) with content
	mkdir ${MOUNT_POINT}/directory_ads1
	echo "My directory ADS" > ${MOUNT_POINT}/directory_ads1:myads

	# Create a symbolic link with an alternate data stream (ADS) with content
	ln -s ${MOUNT_POINT}/directory_ads1 ${MOUNT_POINT}/directory_ads1_symboliclink1
	echo "My symbolic link ADS" > ${MOUNT_POINT}/directory_ads1_symboliclink1:myads

	# Create an LZNT1 compressed file if supported
	mkdir ${MOUNT_POINT}/compressed

	setfattr -h -v 0x00080000 -n system.ntfs_attrib ${MOUNT_POINT}/compressed

	cp LICENSE ${MOUNT_POINT}/compressed/
}

assert_availability_binary dd;
assert_availability_binary mkntfs;

set -e;

SPECIMENS_PATH="specimens/mkntfs";

mkdir -p ${SPECIMENS_PATH};

MOUNT_POINT="/mnt/ntfs";

sudo mkdir -p ${MOUNT_POINT};

# Minimum NTFS volume size is 1 MiB.
DEFAULT_IMAGE_SIZE=$(( 4096 * 1024 ));

IMAGE_SIZE=${DEFAULT_IMAGE_SIZE};
SECTOR_SIZE=512;

# Create a NTFS file system
IMAGE_NAME="ntfs.raw"
IMAGE_FILE="${SPECIMENS_PATH}/${IMAGE_NAME}";

dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE};

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

create_test_file_entries ${MOUNT_POINT};

sudo umount ${MOUNT_POINT};

# Create a NTFS file system without ADS support (streams_interface=windows)
IMAGE_NAME="ntfs_no_ads.raw"
IMAGE_FILE="${SPECIMENS_PATH}/${IMAGE_NAME}";

dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE};

sudo mount -o loop,rw,compression ${IMAGE_FILE} ${MOUNT_POINT};

create_test_file_entries ${MOUNT_POINT};

sudo umount ${MOUNT_POINT};

# Create NTFS file systems with a specific cluster (block) sizes and bytes per sector.
for CLUSTER_SIZE in 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152;
do
	for SECTOR_SIZE in 256 512 1024 2048 4096;
	do
		# Note that mkntfs requires the cluster size to be greater or equal the sector size or
		# the cluster size less than or equal 4096 times the size of the sector size.
		if test ${CLUSTER_SIZE} -lt ${SECTOR_SIZE} || test ${CLUSTER_SIZE} -gt $(( ${SECTOR_SIZE} * 4096 ));
		then
			continue;
		fi
		IMAGE_NAME="ntfs_cluster_${CLUSTER_SIZE}_sector_${SECTOR_SIZE}.raw"
		IMAGE_FILE="${SPECIMENS_PATH}/${IMAGE_NAME}";

		# Make sure the image has more than 32 cluster blocks
		IMAGE_SIZE=$(( ${CLUSTER_SIZE} * 48 ));

		if test ${IMAGE_SIZE} -lt ${DEFAULT_IMAGE_SIZE};
		then
			IMAGE_SIZE=${DEFAULT_IMAGE_SIZE};
		fi
		dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

		mkntfs -F -q -L "ntfs_test" -c ${CLUSTER_SIZE} -s ${SECTOR_SIZE} ${IMAGE_FILE};

		# NTFS3g does not support a cluster size of 256.
		if test ${CLUSTER_SIZE} -gt 256;
		then
			sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

			create_test_file_entries ${MOUNT_POINT};

			sudo umount ${MOUNT_POINT};
		fi
	done
done

# Create a NTFS file system with many files
SECTOR_SIZE=512;

# 1000000 is disabled for now since it creates a 2 GiB test image and
# a while to generate causing sudo to time out.
for NUMBER_OF_FILES in 100 1000 10000 100000;
do
	if test ${NUMBER_OF_FILES} -eq 10000000;
	then
		# TODO: this is an guestimate
		IMAGE_SIZE=$(( 8192 * 4096 * 1024 ));

	elif test ${NUMBER_OF_FILES} -eq 1000000;
	then
		IMAGE_SIZE=$(( 512 * 4096 * 1024 ));

	elif test ${NUMBER_OF_FILES} -eq 100000;
	then
		IMAGE_SIZE=$(( 32 * 4096 * 1024 ));

	elif test ${NUMBER_OF_FILES} -eq 10000;
	then
		IMAGE_SIZE=$(( 4 * 4096 * 1024 ));
	else
		IMAGE_SIZE=${DEFAULT_IMAGE_SIZE};
	fi

	IMAGE_NAME="ntfs_${NUMBER_OF_FILES}_files.raw"
	IMAGE_FILE="${SPECIMENS_PATH}/${IMAGE_NAME}";

	dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

	mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE};

	sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

	create_test_file_entries ${MOUNT_POINT};

	# Create additional files
	for NUMBER in `seq 3 ${NUMBER_OF_FILES}`;
	do
		if test $(( ${NUMBER} % 2 )) -eq 0;
		then
			touch ${MOUNT_POINT}/testdir1/TestFile${NUMBER};
		else
			touch ${MOUNT_POINT}/testdir1/testfile${NUMBER};
		fi
	done

	sudo umount ${MOUNT_POINT};
done

# Create a NTFS file system with several corrupted files.
IMAGE_NAME="ntfs_corrupted.raw"
IMAGE_SIZE=${DEFAULT_IMAGE_SIZE};
IMAGE_FILE="${SPECIMENS_PATH}/${IMAGE_NAME}";

dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE};

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

mkdir ${MOUNT_POINT}/compressed;

setfattr -h -v 0x00080000 -n system.ntfs_attrib ${MOUNT_POINT}/compressed

cp LICENSE ${MOUNT_POINT}/compressed/lznt1_empty

# Make sure the lznt1 compressed data run is large enough to store lznt1.bin
cp LICENSE ${MOUNT_POINT}/compressed/lznt1_truncated
cat LICENSE >> ${MOUNT_POINT}/compressed/lznt1_truncated

sudo umount ${MOUNT_POINT};

# Make sure to unmount before making modifications to the data streams

# TODO: determine extent of lznt1_empty file and fill with 0-byte values
dd conv=notrunc if=/dev/zero of=${IMAGE_FILE} bs=4096 seek=$(( 0x000e9000 / 4096 )) count=$(( 12288 / 4096 ))

# TODO: determine extent of lznt1_truncated file and fill first 0x4000 bytes with lznt1.bin and the remainder with with 0-byte values
dd conv=notrunc if=/dev/zero of=${IMAGE_FILE} bs=4096 seek=$(( 0x000ec000 / 4096 )) count=$(( 20480 / 4096 ))
dd conv=notrunc if=lznt1.bin of=${IMAGE_FILE} bs=4096 seek=$(( 0x000ec000 / 4096 ))

exit ${EXIT_SUCCESS};

