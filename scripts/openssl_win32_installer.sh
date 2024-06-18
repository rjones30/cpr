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
    echo "Usage: openssl_win32_installer.sh <install_prefix> <perl> <cc>"
    echo " where <install_prefix>/lib is the intended destination"
    echo " for the openssl libraries, <perl> is the full path"
    echo " to the perl executable needed to build openssl, and <cc>"
    echo " is the full path to the Visual Studio c++ compiler."
    exit 1
}
function error_exit() {
    echo "openssl_win32_installer.sh error - $2"
    exit $1
}

if [ $# -ne 3 ]; then
    usage
elif ! which curl >/dev/null 2>/dev/null; then
    error_exit $? "curl command is not available, cannot continue."
else
    install_prefix=$1
    perl=$2
    cl=$3
fi

perl --version
if [ $? != 0 ]; then
    echo "perl command is not in the PATH: $perl"
    export PATH=$PATH:$(dirname $perl)
    perl --version
fi

nmake -P
if [ $? != 0 ]; then
    nmake=$(echo $cl | sed 's/cl.exe/nmake.exe/')
    "$nmake" -P
fi

curl $release -o $tarball || error_exit $? "unable to GET $release"
tar -zxf $tarball
source=$(echo $tarball | sed 's/.tar.gz$//')
cd $source
"$nmake" -f win32\Makefile INST_TOP="$install_prefix"
"$nmake" -f win32\Makefile install

if ! $install_prefix/bin/openssl version; then
    error_exit $? "openssl installation failed"
else
    echo "openssl installation completed successfully!"
fi
