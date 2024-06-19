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
    install_prefix=$1
    clexe=$2
fi

export PATH=$install_prefix/perl/bin:$PATH
echo "PATH is now $PATH"
hash -r
$install_prefix/perl/bin/perl --version
echo "perl executable is" $(which perl)
perl --version
perl -MCPAN -e 'install Locale::Maketext::Simple'

nmake -P
if [ $? != 0 ]; then
    nmake=$(echo $clexe | sed 's/cl.exe/nmake.exe/')
    "$nmake" -P
fi

curl $release -o $tarball || error_exit $? "unable to GET $release"
tar -zxf $tarball
source=$(echo $tarball | sed 's/.tar.gz$//')
cd $source
./config no-shared --prefix=$install_prefix --openssldir=$install_prefix
"$nmake" -f Makefile VERBOSE=1 INST_TOP="$install_prefix"
"$nmake" -f Makefile install

if ! $install_prefix/bin/openssl version; then
    error_exit $? "openssl installation failed"
else
    echo "openssl installation completed successfully!"
fi
