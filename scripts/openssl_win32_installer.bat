@echo off
REM
REM openssl_win32_installer.bat - script to install openssl in userspace
REM                               on a generic win32 host from sources, assuming that
REM                               development tools (gnu compilers, linker) and the
REM                               curl utility are already present.
REM
REM author: richard.t.jones at uconn.edu
REM version: june 5, 2024

setlocal

set "openssl_version=3.2.1"
set "openssl_tarball_url=https://www.openssl.org/source/openssl-%openssl_version%.tar.gz"
set "nasm_version=2.16"
set "nasm_zip_url=https://www.nasm.us/pub/nasm/releasebuilds/%nasm_version%/win64/nasm-%nasm_version%-win64.zip"
set "nasm_zip_url=https://www.nasm.us/pub/nasm/releasebuilds/%nasm_version%/win32/nasm-%nasm_version%-win32.zip"

for /f "delims=" %%i in ('powershell -Command "$input = '%2'; $pattern = '\\Community\\.*'; $replacement = '\Community\VC\Auxiliary\Build\vcvarsall.bat'; $result = [regex]::Replace($input, $pattern, $replacement); Write-Output $result"') do set "vcvarsall_bat1=%%i"
for /f "delims=" %%i in ('powershell -Command "$input = '%vcvarsall_bat1%'; $pattern = '\\Enterprise\\.*'; $replacement = '\Enterprise\VC\Auxiliary\Build\vcvarsall.bat'; $result = [regex]::Replace($input, $pattern, $replacement); Write-Output $result"') do set "vcvarsall_bat=%%i"
call "%vcvarsall_bat%" x86_amd64

echo Verifying nmake installation...
nmake -P

echo Downloading NASM...
curl -L -o nasm.zip "%nasm_zip_url%"
echo "install into %1\nasm-%nasm_version%"
powershell -Command "& {Expand-Archive -Path nasm.zip -DestinationPath %1 -Force}"
del nasm.zip
set "PATH=%1\nasm-%nasm_version%;%PATH%"
echo Verifying NASM installation...
nasm -v
echo NASM installation completed.

curl -L %openssl_tarball_url% -o "openssl-%openssl_version%.tar.gz"
tar -zxf openssl-%openssl_version%.tar.gz
set "source=openssl-%openssl_version%"
cd %source%
set "PATH=%1\perl\bin;%PATH%"
perl --version
perl Configure no-shared --prefix="%1" --openssldir="%1"
nmake VERBOSE=1 INST_TOP="%1" -j4
nmake install

endlocal
