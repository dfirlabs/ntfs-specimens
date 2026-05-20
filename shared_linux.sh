#!/bin/bash
#
# Shared functionality for scripts to generate NTFS test files

EXIT_SUCCESS=0
EXIT_FAILURE=1

# Checks the availability of a binary and exits if not available.
#
# Arguments:
#   a string containing the name of the binary
#
assert_availability_binary()
{
	local BINARY=$1

	which ${BINARY} > /dev/null 2>&1
	if test $? -ne ${EXIT_SUCCESS}
	then
		echo "Missing binary: ${BINARY}"
		echo ""

		exit ${EXIT_FAILURE}
	fi
}

# Creates test file entries.
#
# Arguments:
#   a string containing the mount point of the image file
#
create_test_file_entries()
{
	MOUNT_POINT=$1

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
