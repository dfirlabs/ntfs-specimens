#!/bin/bash
#
# Script to generate NTFS test files for testing Unicode conversions
# Requires Linux with dd and mkntfs and unicodetouch of the libyal assorted project.

EXIT_SUCCESS=0;
EXIT_FAILURE=1;

UNICODETOUCH="${HOME}/Projects/assorted/src/unicodetouch";

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

create_test_file_entries_unicode()
{
	MOUNT_POINT=$1;

	# Create a directory
	mkdir ${MOUNT_POINT}/testdir1

	set +e;

	# Create a file for Unicode characters defined in UnicodeData.txt
	for NUMBER in `cat UnicodeData.txt | sed 's/;.*$//'`;
	do
		UNICODE_CHARACTER=`printf "%08x" $(( 0x${NUMBER} ))`;

		# There are different methods to generate file names with Unicode characters
		# using unicodetouch is currently the most comprehensive method.

		# touch `python2 -c "print(''.join(['${MOUNT_POINT}/testdir1/unicode_U+${UNICODE_CHARACTER}_', '${UNICODE_CHARACTER}'.decode('hex').decode('utf-32-be')]).encode('utf-8'))"` 2> /dev/null;

		# touch `python3 -c "print(''.join(['${MOUNT_POINT}/testdir1/unicode_U+{0:08x}_'.format(0x${NUMBER}), eval('\\\\'\\\\\\\\U{0:08x}\\\\''.format(0x${NUMBER}))]))"` 2> /dev/null;

		# if test $? -ne 0;
		# then
		# 	echo "Unsupported: 0x${UNICODE_CHARACTER}";
		# fi

		# CHARACTER=`/usr/bin/printf "\\U${UNICODE_CHARACTER}" 2> /dev/null`;

		# if test -z ${CHARACTER};
		# then
		# 	echo "Unsupported: 0x${UNICODE_CHARACTER}";
		# else
		# 	touch "${MOUNT_POINT}/testdir1/unicode_U+${UNICODE_CHARACTER}_${CHARACTER}";
		# fi

		(cd ${MOUNT_POINT}/testdir1 && ${UNICODETOUCH} $(( 0x${NUMBER} )) &> /dev/null)

		if test $? -ne 0;
		then
			echo "Unsupported: 0x${UNICODE_CHARACTER}";
		fi
	done

	set -e;
}

assert_availability_binary dd;
assert_availability_binary mkntfs;
assert_availability_binary ${UNICODETOUCH};

SPECIMENS_PATH="specimens/mkntfs";

if ! test -f "UnicodeData.txt";
then
	echo "Missing UnicodeData.txt file. UnicodeData.txt can be obtained from "
	echo "unicode.org make sure you have a local copy in the current working ";
	echo "directory.";

	exit ${EXIT_FAILURE};
fi

if test -d ${SPECIMENS_PATH};
then
	echo "Specimens directory: ${SPECIMENS_PATH} already exists.";

	exit ${EXIT_FAILURE};
fi

mkdir -p ${SPECIMENS_PATH};

set -e;

MOUNT_POINT="/mnt/ntfs";

sudo mkdir -p ${MOUNT_POINT};

IMAGE_SIZE=$(( 64 * 1024 * 1024 ));
SECTOR_SIZE=512;

# Create raw disk image with a NTFS file system and files for individual Unicode characters
IMAGE_FILE="${SPECIMENS_PATH}/ntfs_unicode_files.raw";

dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE};

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

create_test_file_entries_unicode ${MOUNT_POINT}

sudo umount ${MOUNT_POINT};

exit ${EXIT_SUCCESS};

