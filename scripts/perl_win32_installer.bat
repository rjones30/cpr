@echo off
REM
REM perlwin32_installer.sh - script to install perl with CPAN in userspace
REM                          on a win32 host from sources, assuming that
REM                          development tools (msvc compilers, linker)
REM                          and the bitsdadmin utility are already present.
REM
REM author: richard.t.jones at uconn.edu
REM version: june 5, 2024

setlocal

REM Define the URL for the Strawberry Perl installer
set "perlInstallerUrl=https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit.msi"
REM Define the local path to download the installer
set "installerPath=%TEMP%\strawberry-perl-5.32.1.1-64bit.msi"

REM Download the installer
echo Downloading Strawberry Perl installer...
rem bitsadmin /transfer "DownloadPerl" /priority normal %perlInstallerUrl% %installerPath%
curl %perlInstallerUrl% -o %installerPath%

REM Install Strawberry Perl silently
set "installdir=%1"
echo Installing Strawberry Perl in %installdir% ...
msiexec /i "%installerPath%" INSTALLDIR="%installdir%" ALLUSERS=2 /quiet

dir /S "%installdir%"

REM Verify the installation
echo Verifying the Perl installation...
set "perlPath=%installdir%\perl\bin\perl.exe"
if exist "%perlPath%" (
    "%perlPath%" -v
    echo Perl installed successfully.
) else (
    echo Perl installation failed.
)

REM Clean up the installer file
del "%installerPath%"
echo Installer file removed.

endlocal
