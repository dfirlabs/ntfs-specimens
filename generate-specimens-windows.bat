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

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system with compression
set unitsize=4096
set imagename=ntfs_compress.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick compress >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 512
set unitsize=512
set imagename=ntfs_%unitsize%.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 1024
set unitsize=1024
set imagename=ntfs_%unitsize%.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 2048
set unitsize=2048
set imagename=ntfs_%unitsize%.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 4096
set unitsize=4096
set imagename=ntfs_%unitsize%.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 8192
set unitsize=8192
set imagename=ntfs_%unitsize%.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 16k
set unitsize=16k
set imagename=ntfs_%unitsize%.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 32k
set unitsize=32k
set imagename=ntfs_%unitsize%.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 64k
set unitsize=64k
set imagename=ntfs_%unitsize%.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 128k
set unitsize=128k
set imagename=ntfs_%unitsize%.vhd
set imagesize=8

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
rem The start of the partition must be aligned with the (cluster block) unit size.
echo create partition primary align=128 >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 256k
set unitsize=256k
set imagename=ntfs_%unitsize%.vhd
set imagesize=16

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
rem The start of the partition must be aligned with the (cluster block) unit size.
echo create partition primary align=256 >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 512k
set unitsize=512k
set imagename=ntfs_%unitsize%.vhd
set imagesize=16

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
rem The start of the partition must be aligned with the (cluster block) unit size.
echo create partition primary align=512 >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 1m
set unitsize=1m
set imagename=ntfs_%unitsize%.vhd
set imagesize=32

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
rem The start of the partition must be aligned with the (cluster block) unit size.
echo create partition primary align=1024 >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=1024k quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

rem Create a fixed-size VHD image with a NTFS file system and unit size 2m
set unitsize=2m
set imagename=ntfs_%unitsize%.vhd
set imagesize=64

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=fixed > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
rem The start of the partition must be aligned with the (cluster block) unit size.
echo create partition primary align=2048 >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=2048k quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

call :create_test_file_entries x

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

exit /b 0

rem Creates test file entries
:create_test_file_entries
SETLOCAL
SET driveletter=%1

rem Create an emtpy file
type nul >> %driveletter%:\emptyfile

rem Create a directory
mkdir %driveletter%:\testdir1

rem Create a file with a resident MFT data attribure
echo My file > %driveletter%:\testdir1\testfile1

rem Create a file with a non-resident MFT data attribute
copy LICENSE %driveletter%:\testdir1\testfile2

rem Create a file with a long filename
type nul >> "%driveletter%:\My long, very long file name, so very long"

rem Create an LZNT1 compressed file if supported
rem copy LICENSE %driveletter%:\testdir1\compressed1
rem compact /c /f /q %driveletter%:\testdir1\compressed1

rem Create LZXPRESS 4k compressed files
copy BINARY %driveletter%:\testdir1\lzxpress4k_compressed1
compact /c /exe:XPRESS4K /f /q %driveletter%:\testdir1\lzxpress4k_compressed1

rem Create LZXPRESS 8k compressed files
copy BINARY %driveletter%:\testdir1\lzxpress8k_compressed1
compact /c /exe:XPRESS8K /f /q %driveletter%:\testdir1\lzxpress8k_compressed1

rem Create LZXPRESS 16k compressed files
copy BINARY %driveletter%:\testdir1\lzxpress16k_compressed1
compact /c /exe:XPRESS16K /f /q %driveletter%:\testdir1\lzxpress16k_compressed1

rem Create LZX compressed files
rem Use multiple samples for the different modes of LZX compression
copy BINARY %driveletter%:\testdir1\lzx_compressed1
compact /c /exe:LZX /f /q %driveletter%:\testdir1\lzx_compressed1

copy BINARY.upx %driveletter%:\testdir1\lzx_compressed2
compact /c /exe:LZX /f /q %driveletter%:\testdir1\lzx_compressed2

copy BINARY.gz %driveletter%:\testdir1\lzx_compressed3
compact /c /exe:LZX /f /q %driveletter%:\testdir1\lzx_compressed3

rem Create a hard link to a file
mklink /H %driveletter%:\file_hardlink1 %driveletter%:\testdir1\testfile1

rem Create a symbolic link to a file
mklink %driveletter%:\file_symboliclink1 %driveletter%:\testdir1\testfile1

rem Create a junction (hard link to a directory)
mklink /J %driveletter%:\directory_junction1 %driveletter%:\testdir1

rem Create a symbolic link to a directory
mklink /D %driveletter%:\directory_symboliclink1 %driveletter%:\testdir1

rem Create a file with an altenative data stream (ADS)
type nul >> %driveletter%:\file_ads1
echo My file ADS > %driveletter%:\file_ads1:myads

rem Create a directory with an altenative data stream (ADS)
mkdir %driveletter%:\directory_ads1
echo My directory ADS > %driveletter%:\directory_ads1:myads

rem Create a case-sensitive directory
rem This requires Microsoft-Windows-Subsystem-Linux to be enabled
rem Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
mkdir %driveletter%:\testdir2\normal
mkdir %driveletter%:\testdir2\sensitive
fsutil file setCaseSensitiveInfo %driveletter%:\testdir2\sensitive enable

echo My second file > %driveletter%:\testdir2\normal\testfile1
echo My second file > %driveletter%:\testdir2\sensitive\testfile1

echo My third file > %driveletter%:\testdir2\normal\TestFile1
echo My third file > %driveletter%:\testdir2\sensitive\TestFile1

rem TODO: add test case that sets the valid data size
rem fsutil file setValidData file size

rem TODO: add test case that sets the short name
rem fsutil file setShortName

rem TODO: add test case that sets a sparse extent
rem fsutil file setZeroData
rem fsutil sparse

rem TODO: add test case that sets an object identifier
rem fsutil objectid set

ENDLOCAL
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

