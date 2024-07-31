#!/bin/bash
#
# openssl_win32_installer.sh - script to install openssl in userspace
#                              on a generic win32 host from sources, assuming that
#                              development tools (gnu compilers, linker) and the
#                              curl utility are already present.
#
# author: richard.t.jones at uconn.edu
# version: june 5, 2024

release="https://www.openssl.org/source/openssl-3.2.2.tar.gz"
tarball=$(basename $release)

function usage() {
    echo "Usage: openssl_win32_installer.sh <install_prefix> <cc>"
    echo " where <install_prefix>/lib is the intended destination"
    echo " for the openssl libraries, and <cc> is the full path"
    echo " to the Visual Studio c++ compiler."
    exit 1
}
function error_exit() {
    echo "openssl_win32_installer.sh error - $2"
    exit $1
}

if [ $# -ne 2 ]; then
    usage
elif ! which curl >/dev/null 2>/dev/null; then
    error_exit $? "curl command is not available, cannot continue."
else
    install_prefix=$(echo $1 | awk -F: '{print "/"tolower($1)$2}')
    clexe=$(echo $2 | awk -F: '{print "/"tolower($1)$2}')
fi

msvs_prefix=$(echo $clexe | sed s'|/cl.exe$||')
export PATH="$install_prefix/perl/bin:$msvs_prefix:$PATH"
echo "PATH is $PATH"
echo "perl executable is" $(which perl)
perl --version

nmake -P
nasm -v
if [ $? != 0 ]; then
    echo "Downloading NASM..."
    nasm_version=2.16
    nasm_zip_url="https://www.nasm.us/pub/nasm/releasebuilds/$nasm_version/win64/nasm-$nasm_version-win64.zip"
    curl -L -o nasm.zip $nasm_zip_url
    echo "Extracting NASM..."
    powershell -Command "& {Expand-Archive -Path nasm.zip -DestinationPath $1}"
    rm -rf nasm.zip
    export PATH="$PATH:$install_prefix/nasm-$nasm_version"
    echo "Verifying NASM installation"
    nasm -v
fi

curl -L $release -o $tarball || error_exit $? "unable to GET $release"
tar -zxf $tarball
source=$(echo $tarball | sed 's/.tar.gz$//')
cd $source
echo "running config: ./config no-shared --prefix=$install_prefix --openssldir=$install_prefix"
./config no-shared --prefix="$install_prefix" --openssldir="$install_prefix"
if [ $? != 0 ]; then
    echo "config failed, trying again with ./config no-shared --prefix=$1 --openssldir=$1"
    ./Configure no-shared --prefix="$1" --openssldir="$1"
    if [ $? != 0 ]; then
        win_install_prefix=$(echo $1 | sed 's|/|\\|g')
        echo "config failed again, trying again with ./config no-shared --prefix=$win_install_prefix --openssldir=$win_install_prefix"
        ./Configure --prefix="$win_install_prefix" --openssldir="$win_install_prefix"
        if [ $? != 0 ]; then
            echo "no way, no how, giving up!"
        fi
    fi
fi
nmake -f Makefile VERBOSE=1 INST_TOP="$install_prefix"
nmake -f Makefile install

if ! "$install_prefix/bin/openssl" version; then
    error_exit $? "openssl installation failed"
else
    echo "openssl installation completed successfully!"
fi
