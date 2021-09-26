#!/bin/bash
#
# Script to generate NTFS test files

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

assert_availability_binary dd;
assert_availability_binary mkntfs;

set -e;

SPECIMENS_PATH="specimens/mkntfs";

mkdir -p ${SPECIMENS_PATH};

MOUNT_POINT="/mnt/ntfs";

sudo mkdir -p ${MOUNT_POINT};

DEFAULT_IMAGE_SIZE=$(( 4096 * 1024 ));

IMAGE_SIZE=${DEFAULT_IMAGE_SIZE};
SECTOR_SIZE=512;

# Scenario 1:
# 1. Create a file and directory
# 2. Modify the content of the file
# 3. Rename the file
# 4. Remove the file
# 5. Rename the directory
# 6. Remove the directory

# Create an NTFS file system.
IMAGE_FILE="${SPECIMENS_PATH}/ntfs.raw";

dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE};

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 1 create a file and directory.
echo "testfile1" > ${MOUNT_POINT}/testfile1
mkdir ${MOUNT_POINT}/testdir1

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario1.1.raw;

# Sleep so that changes are noticeable.
sleep 5;

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 2 modify the content of a file.
echo "1eliftset" > ${MOUNT_POINT}/testfile1

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario1.2.raw;

# Sleep so that changes are noticeable.
sleep 5;

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 3 rename a file.
mv ${MOUNT_POINT}/testfile1 ${MOUNT_POINT}/1eliftset;

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario1.3.raw;

# Sleep so that changes are noticeable.
sleep 5;

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 4 remove a file.
rm -f ${MOUNT_POINT}/1eliftset;

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario1.4.raw;

# Sleep so that changes are noticeable.
sleep 5;

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 5 rename a directory.
mv ${MOUNT_POINT}/testdir1 ${MOUNT_POINT}/1ridtset;

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario1.5.raw;

# Sleep so that changes are noticeable.
sleep 5;

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 6 remove a directory.
rm -rf ${MOUNT_POINT}/1ridtset;

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario1.6.raw;

# Remove the working image file.
rm -f ${IMAGE_FILE};

# Scenario 2:
# TODO implement

# Scenario 3:
# 1. Create a file in a directory
# 2. Create hard links in directories.

# Create an NTFS file system.
IMAGE_FILE="${SPECIMENS_PATH}/ntfs.raw";

dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE};

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 1 create files and directories.
mkdir ${MOUNT_POINT}/testdir1
echo "testfile1" > ${MOUNT_POINT}/testdir1/testfile1

# Step 2 create hard links in directories.
mkdir ${MOUNT_POINT}/testdir2
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir2/hardlink1

mkdir ${MOUNT_POINT}/testdir3
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir3/hardlink2

mkdir ${MOUNT_POINT}/testdir4
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir4/hardlink3

mkdir ${MOUNT_POINT}/testdir5
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir5/hardlink4

mkdir ${MOUNT_POINT}/testdir6
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir6/hardlink5

mkdir ${MOUNT_POINT}/testdir7
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir7/hardlink6

mkdir ${MOUNT_POINT}/testdir8
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir8/hardlink7

mkdir ${MOUNT_POINT}/testdir9
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir9/hardlink8

mkdir ${MOUNT_POINT}/testdir10
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir10/hardlink9

mkdir ${MOUNT_POINT}/testdir11
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir11/hardlink10

mkdir ${MOUNT_POINT}/testdir12
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir12/hardlink11

mkdir ${MOUNT_POINT}/testdir13
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir13/hardlink12

mkdir ${MOUNT_POINT}/testdir14
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir14/hardlink13

mkdir ${MOUNT_POINT}/testdir15
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir15/hardlink14

mkdir ${MOUNT_POINT}/testdir16
ln ${MOUNT_POINT}/testdir1/testfile1 ${MOUNT_POINT}/testdir16/hardlink15

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario3.1.raw;

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 3 remove hard links.

rm -f ${MOUNT_POINT}/testdir3/hardlink2;
rm -f ${MOUNT_POINT}/testdir5/hardlink4;
rm -f ${MOUNT_POINT}/testdir7/hardlink6;
rm -f ${MOUNT_POINT}/testdir9/hardlink8;
rm -f ${MOUNT_POINT}/testdir11/hardlink10;
rm -f ${MOUNT_POINT}/testdir13/hardlink12;
rm -f ${MOUNT_POINT}/testdir15/hardlink14;

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario3.2.raw;

# Remove the working image file.
rm -f ${IMAGE_FILE};

# Scenario 4:
# 1. Create a file containing a pipe (|) in the name. The pipe character is used by the bodyfile format as a separator.
# 2. Create a file containing backslash (\\) in the name. The backslash character is used by the bodyfile format as escape character.
# 3. Create a file containing a containing a control character in the name and a hardlink with a carrot (^) instead of the control characters.
# 4. Create a file named $OrphanFiles.

# Create an NTFS file system.
IMAGE_FILE="${SPECIMENS_PATH}/ntfs.raw";

dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE};

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 1 create a file containing pipe (|) in the name
echo "file with pipes" > "${MOUNT_POINT}/file\|with\|pipes"

# Step 2 create a file containing backslashes (\\) in the name
echo "file with backslashes" > "${MOUNT_POINT}/file\\\\with\\\\backslashes"

# Step 3 create a file containing a control character in the name and a hardlink with a carrot (^) instead of the control characters
touch `printf "${MOUNT_POINT}/file\x03with\x04control\x04codes"`
(cd ${MOUNT_POINT} && ln 'file'$'\003''with'$'\004''control'$'\004''codes' "file^with^control^codes")

# Step 4 create a file named $OrphanFiles
echo "file named $OrphanFiles" > "${MOUNT_POINT}/\$OrphanFiles"

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario4.1.raw;

# Remove the working image file.
rm -f ${IMAGE_FILE};

# Scenario 5:

# Create an NTFS file system.
IMAGE_FILE="${SPECIMENS_PATH}/ntfs.raw";

dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE};

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 1 create a file.
echo "testfile1" > ${MOUNT_POINT}/testfile1

sleep 0.1

# Step 2 alter the access time
touch -a ${MOUNT_POINT}/testfile1

sleep 0.1

# Step 3 alter the modification time
touch -m ${MOUNT_POINT}/testfile1

sleep 0.1

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario5.1.raw;

# Remove the working image file.
rm -f ${IMAGE_FILE};

# Scenario 6:
# Based on https://github.com/log2timeline/plaso/issues/3840

# Create an NTFS file system.
IMAGE_FILE="${SPECIMENS_PATH}/ntfs.raw";

dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} )) 2> /dev/null;

mkntfs -F -q -L "ntfs_test" -s ${SECTOR_SIZE} ${IMAGE_FILE};

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 1 create a file and directory.
mkdir ${MOUNT_POINT}/testdir1
echo "testfile1" > ${MOUNT_POINT}/testdir1/testfile1

# Step 2 ensure $FILE_NAME of testdir1 is stored in an attribute list.
echo "ads1" > ${MOUNT_POINT}/testdir1:ads1
echo "ads2" > ${MOUNT_POINT}/testdir1:ads2
echo "ads3" > ${MOUNT_POINT}/testdir1:ads3
echo "ads4" > ${MOUNT_POINT}/testdir1:ads4
echo "ads5" > ${MOUNT_POINT}/testdir1:ads5
echo "ads6" > ${MOUNT_POINT}/testdir1:ads6
echo "ads7" > ${MOUNT_POINT}/testdir1:ads7
echo "ads8" > ${MOUNT_POINT}/testdir1:ads8
echo "ads9" > ${MOUNT_POINT}/testdir1:ads9
echo "ads10" > ${MOUNT_POINT}/testdir1:ads10
echo "ads11" > ${MOUNT_POINT}/testdir1:ads11
echo "ads12" > ${MOUNT_POINT}/testdir1:ads12
echo "ads13" > ${MOUNT_POINT}/testdir1:ads13
echo "ads14" > ${MOUNT_POINT}/testdir1:ads14
echo "ads15" > ${MOUNT_POINT}/testdir1:ads15
echo "ads16" > ${MOUNT_POINT}/testdir1:ads16

sleep 0.1

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario6.1.raw;

sudo mount -o loop,rw,compression,streams_interface=windows ${IMAGE_FILE} ${MOUNT_POINT};

# Step 3 remove a directory.
rm -rf ${MOUNT_POINT}/testdir1;

sleep 0.1

# Step 4 create a file.
# This steps assumes the MFT entry previously used by testdir1 is reused for testfile2.
echo "testfile2" > ${MOUNT_POINT}/testfile2

sudo umount ${MOUNT_POINT};

cp ${IMAGE_FILE} ${SPECIMENS_PATH}/ntfs-scenario6.2.raw;

# Remove the working image file.
rm -f ${IMAGE_FILE};

exit ${EXIT_SUCCESS};

