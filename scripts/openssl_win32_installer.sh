#!/bin/bash
#
# openssl_win32_installer.sh - script to install openssl in userspace
#                              on a generic win32 host from sources, assuming that
#                              development tools (gnu compilers, linker) and the
#                              curl utility are already present.
#
# author: richard.t.jones at uconn.edu
# version: june 5, 2024

release="https://www.openssl.org/source/openssl-3.2.1.tar.gz"
tarball=$(basename $release)

function usage() {
    echo "Usage: openssl_win32_installer.sh <install_prefix> <perl>"
    echo " where <install_prefix>/lib is the intended destination"
    echo " for the openssl libraries, and <perl> is the full path"
    echo " to the perl executable needed to build openssl."
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
    install_prefix=$1
    perl=$2
fi

perl --version
if [ $? != 0 ]; then
    echo "perl command is not in the PATH: $perl"
    export PATH=$PATH:$(dirname $perl)
    perl --version
fi

curl $release -o $tarball || error_exit $? "unable to GET $release"
tar -zxf $tarball
source=$(echo $tarball | sed 's/.tar.gz$//')
cd $source
./Configure VC-WIN64A --prefix="$install_prefix" --openssldir=$install_prefix
cd ..
mkdir build.openssl
cd build.openssl
cmake -A Win32 -DCMAKE_INSTALL_PREFIX="$install_prefix" ../$source
cmake --build . --config Release
cmake --install .

if ! $install_prefix/bin/openssl version; then
    error_exit $? "openssl installation failed"
else
    echo "openssl installation completed successfully!"
fi
