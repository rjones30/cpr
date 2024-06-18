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
    echo "Usage: openssl_win32_installer.sh <install_prefix> <make>"
    echo " where <install_prefix>/lib is the intended destination"
    echo " for the openssl libraries, and <make> is the make binary."
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
    make=$2
fi

export PATH=$install_prefix/bin:$PATH
if ! perl -MCPAN -e update CPAN 2>/dev/null >/dev/null; then
    error_exit $? "perl CPAN is not installed, cannot continue."
fi

curl $release -o $tarball || error_exit $? "unable to GET $release"
tar -zxf $tarball
source=$(echo $tarball | sed 's/.tar.gz$//')
cd $source
./config no-shared --prefix=$install_prefix --openssldir=$install_prefix
$make
$make install

if ! $install_prefix/bin/openssl version; then
    error_exit $? "openssl installation failed"
else
    echo "openssl installation completed successfully!"
fi
