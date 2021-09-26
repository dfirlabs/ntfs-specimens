@echo off

rem Script to generate NTFS test files
rem Requires Windows 7 or later

rem Split the output of ver e.g. "Microsoft Windows [Version 10.0.10586]"
rem and keep the last part "10.0.10586]".
for /f "tokens=1,2,3,4" %%a in ('ver') do (
	set version=%%d
)

rem Replace dots by spaces "10 0 10586]".
set version=%version:.= %

rem Split the last part of the ver output "10 0 10586]" and keep the first
rem 2 values formatted with a dot as separator "10.0".
for /f "tokens=1,2,*" %%a in ("%version%") do (
	set version=%%a.%%b
)

rem TODO add check for other supported versions of Windows
rem Also see: https://en.wikipedia.org/wiki/Ver_(command)

if not "%version%" == "10.0" (
	echo Unsupported Windows version: %version%

	exit /b 1
)

set specimenspath=specimens\%version%

if exist "%specimenspath%" (
	echo Specimens directory: %specimenspath% already exists.

	exit /b 1
)

mkdir "%specimenspath%"

rem Supported diskpart format fs=<FS> options: ntfs, fat, fat32
rem Supported diskpart format unit=<N> options: 512, 1024, 2048, 4096 (default), 8192, 16K, 32K, 64K
rem unit=<N> values added in Windows 10 (1903): 128K, 256K, 512K, 1M, 2M

rem Scenario 1:
rem 1. Create a file and directory
rem 2. Modify the content of the file
rem 3. Rename the file
rem 4. Remove the file
rem 5. Rename the directory
rem 6. Remove the directory

rem Create a fixed-size VHD image with a NTFS file system
set unitsize=4096
set imagename=ntfs.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

rem Create an USN journal so we can track file changes in more detail.
fsutil usn createjournal x:

rem Step 1 create a file and directory.
echo "testfile1" > x:\testfile1
mkdir x:\testdir1

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs_scenario1.1.vhd

rem Sleep so that changes are noticeable.
timeout /t 5 /nobreak

echo select vdisk file=%cd%\%specimenspath%\%imagename% > MountVHD.diskpart
echo attach vdisk >> MountVHD.diskpart

echo assign letter=x >> MountVHD.diskpart

call :run_diskpart MountVHD.diskpart

rem Step 2 modify the content of a file.
echo "1eliftset" > x:\testfile1

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs_scenario1.2.vhd

rem Sleep so that changes are noticeable.
timeout /t 5 /nobreak

call :run_diskpart MountVHD.diskpart

rem Step 3 rename a file.
rename x:\testfile1 x:\1eliftset

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs_scenario1.3.vhd

rem Sleep so that changes are noticeable.
timeout /t 5 /nobreak

call :run_diskpart MountVHD.diskpart

rem Step 4 remove a file.
del /f /q x:\1eliftset

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs_scenario1.4.vhd

rem Sleep so that changes are noticeable.
timeout /t 5 /nobreak

call :run_diskpart MountVHD.diskpart

rem Step 5 rename a directory.
move /y x:\testdir1 x:\1ridtset

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs_scenario1.5.vhd

rem Sleep so that changes are noticeable.
timeout /t 5 /nobreak

call :run_diskpart MountVHD.diskpart

rem Step 6 remove a directory
rmdir x:\1ridtset

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs_scenario1.6.vhd

rem Remove the working image file.
del /f /q %specimenspath%\%imagename%

rem Scenario 2:
rem 1. Create files and directories
rem 2. Remove a file
rem 3. Rename a directory

rem Create a fixed-size VHD image with a NTFS file system
set unitsize=4096
set imagename=ntfs.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

rem Create an USN journal so we can track file changes in more detail.
fsutil usn createjournal x:

rem Step 1 create files and directories.
echo "testfile1" > x:\testfile1

mkdir x:\testdir1
echo "testfile2" > x:\testdir1\testfile2

mkdir x:\testdir1\testdir2
echo "testfile3" > x:\testdir1\testdir2\testfile3
echo "testfile4" > x:\testdir1\testdir2\testfile4

rem Windows does not support hardlinks to directories only junctions
mklink /J x:\junction1 x:\testdir1\testdir2
mklink /J x:\junction2 x:\testdir1\testdir2

mkdir x:\testdir3
mklink /H x:\testdir3\hardlink1 x:\testdir1\testdir2\testfile3

rem Step 2 remove a file
del /f /q x:\testdir1\testdir2\testfile4

rmdir x:\junction2

rem Step 3 rename a directory
move /y x:\testdir1\testdir2 x:\testdir1\2ridtset

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs_path_hint.vhd

rem Remove the working image file.
del /f /q %specimenspath%\%imagename%

rem Scenario 3:
rem 1. Create a file in a directory
rem 2. Create hard links in directories.

rem Create a fixed-size VHD image with a NTFS file system
set unitsize=4096
set imagename=ntfs.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

rem Step 1 create files and directories.
mkdir x:\testdir1
echo "testfile1" > x:\testdir1\testfile1

rem Step 2 create hard links in directories.
mkdir x:\testdir2
mklink /H x:\testdir2\hardlink1 x:\testdir1\testfile1

mkdir x:\testdir3
mklink /H x:\testdir3\hardlink2 x:\testdir1\testfile1

mkdir x:\testdir4
mklink /H x:\testdir4\hardlink3 x:\testdir1\testfile1

mkdir x:\testdir5
mklink /H x:\testdir5\hardlink4 x:\testdir1\testfile1

mkdir x:\testdir6
mklink /H x:\testdir6\hardlink5 x:\testdir1\testfile1

mkdir x:\testdir7
mklink /H x:\testdir7\hardlink6 x:\testdir1\testfile1

mkdir x:\testdir8
mklink /H x:\testdir8\hardlink7 x:\testdir1\testfile1

mkdir x:\testdir9
mklink /H x:\testdir9\hardlink8 x:\testdir1\testfile1

mkdir x:\testdir10
mklink /H x:\testdir10\hardlink9 x:\testdir1\testfile1

mkdir x:\testdir11
mklink /H x:\testdir11\hardlink10 x:\testdir1\testfile1

mkdir x:\testdir12
mklink /H x:\testdir12\hardlink11 x:\testdir1\testfile1

mkdir x:\testdir13
mklink /H x:\testdir13\hardlink12 x:\testdir1\testfile1

mkdir x:\testdir14
mklink /H x:\testdir14\hardlink13 x:\testdir1\testfile1

mkdir x:\testdir15
mklink /H x:\testdir15\hardlink14 x:\testdir1\testfile1

mkdir x:\testdir16
mklink /H x:\testdir16\hardlink15 x:\testdir1\testfile1

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs-scenario3.1.vhd

rem Sleep so that changes are noticeable.
timeout /t 5 /nobreak

echo select vdisk file=%cd%\%specimenspath%\%imagename% > MountVHD.diskpart
echo attach vdisk >> MountVHD.diskpart

echo assign letter=x >> MountVHD.diskpart

call :run_diskpart MountVHD.diskpart

rem Step 3 remove hard links.

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs-scenario3.2.vhd

rem Remove the working image file.
del /f /q %specimenspath%\%imagename%

rem Scenario 6:
rem Based on https://github.com/log2timeline/plaso/issues/3840

rem Create a fixed-size VHD image with a NTFS file system
set unitsize=4096
set imagename=ntfs.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

rem Create an USN journal so we can track file changes in more detail.
fsutil usn createjournal x:

rem Step 1 create files and directories.
mkdir x:\testdir1
echo "testfile1" > x:\testdir1\testfile1

rem Step 2 ensure $FILE_NAME of testdir1 is stored in an attribute list.
echo "ads1" > x:\testdir1:ads1
echo "ads2" > x:\testdir1:ads2
echo "ads3" > x:\testdir1:ads3
echo "ads4" > x:\testdir1:ads4
echo "ads5" > x:\testdir1:ads5
echo "ads6" > x:\testdir1:ads6
echo "ads7" > x:\testdir1:ads7
echo "ads8" > x:\testdir1:ads8
echo "ads9" > x:\testdir1:ads9
echo "ads10" > x:\testdir1:ads10
echo "ads11" > x:\testdir1:ads11
echo "ads12" > x:\testdir1:ads12
echo "ads13" > x:\testdir1:ads13
echo "ads14" > x:\testdir1:ads14
echo "ads15" > x:\testdir1:ads15
echo "ads16" > x:\testdir1:ads16

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs-scenario6.1.vhd

rem Sleep so that changes are noticeable.
timeout /t 5 /nobreak

echo select vdisk file=%cd%\%specimenspath%\%imagename% > MountVHD.diskpart
echo attach vdisk >> MountVHD.diskpart

echo assign letter=x >> MountVHD.diskpart

call :run_diskpart MountVHD.diskpart

rem Step 3 remove a directory.
del /f /q /s x:\testdir1
rmdir x:\testdir1

rem Step 4 create a file.
rem This steps assumes the MFT entry previously used by testdir1 is reused for testfile2.
echo "testfile2" > x:\testfile2

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs-scenario6.2.vhd

rem Remove the working image file.
del /f /q %specimenspath%\%imagename%

rem Scenario 7:
rem Variant of scenario 6

rem Create a fixed-size VHD image with a NTFS file system
set unitsize=4096
set imagename=ntfs.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

rem Create an USN journal so we can track file changes in more detail.
fsutil usn createjournal x:

rem Step 1 create files and directories.
mkdir x:\testdir1
echo "testfile1" > x:\testdir1\testfile1
echo "testfile2" > x:\testdir1\testfile2
echo "testfile3" > x:\testdir1\testfile3
echo "testfile4" > x:\testdir1\testfile4
echo "testfile5" > x:\testdir1\testfile5
echo "testfile6" > x:\testdir1\testfile6
echo "testfile7" > x:\testdir1\testfile7
echo "testfile8" > x:\testdir1\testfile8
echo "testfile9" > x:\testdir1\testfile9
echo "testfile10" > x:\testdir1\testfile10
echo "testfile11" > x:\testdir1\testfile11
echo "testfile12" > x:\testdir1\testfile12
echo "testfile13" > x:\testdir1\testfile13
echo "testfile14" > x:\testdir1\testfile14
14ho "testfile15" > x:\testdir1\testfile15
14ho "testfile16" > x:\testdir1\testfile16

rem Step 2 ensure $FILE_NAME of testdir1 is stored in an attribute list.
echo "ads1" > x:\testdir1:ads1
echo "ads2" > x:\testdir1:ads2
echo "ads3" > x:\testdir1:ads3
echo "ads4" > x:\testdir1:ads4
echo "ads5" > x:\testdir1:ads5
echo "ads6" > x:\testdir1:ads6
echo "ads7" > x:\testdir1:ads7
echo "ads8" > x:\testdir1:ads8
echo "ads9" > x:\testdir1:ads9
echo "ads10" > x:\testdir1:ads10
echo "ads11" > x:\testdir1:ads11
echo "ads12" > x:\testdir1:ads12
echo "ads13" > x:\testdir1:ads13
echo "ads14" > x:\testdir1:ads14
echo "ads15" > x:\testdir1:ads15
echo "ads16" > x:\testdir1:ads16

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs-scenario7.1.vhd

rem Sleep so that changes are noticeable.
timeout /t 5 /nobreak

echo select vdisk file=%cd%\%specimenspath%\%imagename% > MountVHD.diskpart
echo attach vdisk >> MountVHD.diskpart

echo assign letter=x >> MountVHD.diskpart

call :run_diskpart MountVHD.diskpart

rem Step 3 remove a directory.
del /f /q /s x:\testdir1
rmdir x:\testdir1

rem Step 4 create a file.
rem This steps assumes the MFT entry previously used by testdir1 is reused for testfile20.
echo "testfile20" > x:\testfile20

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs-scenario7.2.vhd

rem Sleep so that changes are noticeable.
timeout /t 5 /nobreak

echo select vdisk file=%cd%\%specimenspath%\%imagename% > MountVHD.diskpart
echo attach vdisk >> MountVHD.diskpart

echo assign letter=x >> MountVHD.diskpart

call :run_diskpart MountVHD.diskpart

rem Step 5 create a directory.
mkdir x:\testdir1

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

copy %specimenspath%\%imagename% %specimenspath%\ntfs-scenario7.3.vhd

rem Remove the working image file.
del /f /q %specimenspath%\%imagename%

exit /b 0

rem Runs diskpart with a script
rem Note that diskpart requires Administrator privileges to run
:run_diskpart
SETLOCAL
set diskpartscript=%1

rem Note that diskpart requires Administrator privileges to run
diskpart /s %diskpartscript%

if %errorlevel% neq 0 (
	echo Failed to run: "diskpart /s %diskpartscript%"

	exit /b 1
)

del /q %diskpartscript%

rem Give the system a bit of time to adjust
timeout /t 1 > nul

ENDLOCAL
exit /b 0

