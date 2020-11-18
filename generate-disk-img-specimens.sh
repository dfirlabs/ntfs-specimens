#!/bin/bash
#
# Script to combine two NTFS partitions/specimens into a single Volume

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

	command -v "${BINARY}" > /dev/null 2>&1;
	if test $? -ne ${EXIT_SUCCESS};
	then
		echo "Missing binary: ${BINARY}";
		echo "";

		exit ${EXIT_FAILURE};
	fi
}

assert_availability_binary losetup;
assert_availability_binary kpartx;
assert_availability_binary parted;

# exit immediately if a command fails with a none zero.
set -e;

SECTOR_SIZE=512;
TO_ALIGN_PARTITIONS=2048

# the looping device that will be used 
free_device=$(losetup --find | awk -F "/" '{print $3}') 

size_file_1=$(du --block=$SECTOR_SIZE "$1" | awk '{ print $1}') # in blocks
echo "size_file_1: $size_file_1 in blocks of a $SECTOR_SIZE bytes."

size_file_2=$(du --block=$SECTOR_SIZE "$2" | awk '{ print $1}') # in blocks
echo "size_file_2: $size_file_2 in blocks of a $SECTOR_SIZE bytes."

# bs blocksize is 1 byte
total_size=$((size_file_1+size_file_2+TO_ALIGN_PARTITIONS+1))
dd if=/dev/zero of=original.raw bs="${SECTOR_SIZE}" count="${total_size}" status=progress
echo "original.raw size in blocks: $(du --block=$SECTOR_SIZE original.raw | awk '{print $1}')"

# mount in /dev/loop0
losetup -f original.raw
losetup -a 

# partition
startp1="${TO_ALIGN_PARTITIONS}s"
endp1="$((size_file_1+TO_ALIGN_PARTITIONS-1))s" 
startp2="$((size_file_1+TO_ALIGN_PARTITIONS))s"
endp2="$((size_file_1+size_file_2+TO_ALIGN_PARTITIONS-1))s"
parted -s /dev/"${free_device}" mklabel msdos mkpart primary NTFS $startp1 $endp1 mkpart primary NTFS $startp2 $endp2
parted -s /dev/"${free_device}" print

# combine raw partitions into original.img a disk image
kpartx -av original.raw
dd if="$1" of=/dev/mapper/"${free_device}"p1 bs=1M
dd if="$2" of=/dev/mapper/"${free_device}"p2 bs=1M

# cleaning
kpartx -dv original.raw

exit ${EXIT_SUCCESS};
