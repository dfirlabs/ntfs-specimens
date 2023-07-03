@echo off
chcp 65001

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

rem Create a variable-size VHD image with a NTFS file system and files for individual Unicode characters
set unitsize=4096
set imagename=ntfs_unicode_files.vhd
set imagesize=2048

echo create vdisk file=%cd%\%specimenspath%\%imagename% maximum=%imagesize% type=expandable > CreateVHD.diskpart
echo select vdisk file=%cd%\%specimenspath%\%imagename% >> CreateVHD.diskpart
echo attach vdisk >> CreateVHD.diskpart
echo convert mbr >> CreateVHD.diskpart
echo create partition primary >> CreateVHD.diskpart

echo format fs=ntfs label="TestVolume" unit=%unitsize% quick >> CreateVHD.diskpart

echo assign letter=x >> CreateVHD.diskpart

call :run_diskpart CreateVHD.diskpart

set sourcedir=%cd%

mkdir x:\testdir1
pushd x:\testdir1

rem TODO use UnicodeData.txt instead of brute forcing Unicode character space

for /l %%a in (0, 1, 1114111) do call %sourcedir%\unicodetouch.exe %%a > nul

popd

echo select vdisk file=%cd%\%specimenspath%\%imagename% > UnmountVHD.diskpart
echo detach vdisk >> UnmountVHD.diskpart

call :run_diskpart UnmountVHD.diskpart

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

