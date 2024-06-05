@echo off
REM
REM openssl_win32_installer.sh - script to install openssl in userspace
REM                              on a win32 host from sources, assuming that
REM                              development tools (msvc compilers, linker)
REM                              and the bitsdadmin utility are already present.
REM
REM author: richard.t.jones at uconn.edu
REM version: june 5, 2024

setlocal

REM Set OpenSSL version
set OPENSSL_VERSION=openssl-3.2.1

REM Set installation directory
set INSTALL_DIR=C:\OpenSSL-3

REM Set download directory
set DOWNLOAD_DIR=%TEMP%

REM Set URL for OpenSSL source
set OPENSSL_URL=https://www.openssl.org/source/%OPENSSL_VERSION%.tar.gz

REM Download OpenSSL
echo Downloading OpenSSL version %OPENSSL_VERSION%...
curl -L -o %DOWNLOAD_DIR%\%OPENSSL_VERSION%.tar.gz %OPENSSL_URL%

REM Extract the tarball
echo Extracting OpenSSL...
tar zxf %DOWNLOAD_DIR%\%OPENSSL_VERSION%.tar.gz

REM Change to the OpenSSL directory
cd %DOWNLOAD_DIR%\%OPENSSL_VERSION%

REM Configure, build, and install OpenSSL with static libraries
echo Configuring OpenSSL for static libraries...
openssl Configure VC-WIN64A no-shared --prefix=%INSTALL_DIR%

echo Building OpenSSL...
nmake

echo Installing OpenSSL...
nmake install

REM Verify installation
echo Verifying OpenSSL installation...
%INSTALL_DIR%\bin\openssl version

echo OpenSSL %OPENSSL_VERSION% installation completed successfully.

endlocal
pause
