#!/bin/bash

# Copyright(c) 2024 Alex313031

YEL='\033[1;33m' # Yellow
CYA='\033[1;96m' # Cyan
RED='\033[1;31m' # Red
GRE='\033[1;32m' # Green
c0='\033[0m' # Reset Text
bold='\033[1m' # Bold Text
underline='\033[4m' # Underline Text

# Error handling
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "${RED}Failed $*"; }

# --help
displayHelp () {
	printf "\n" &&
	printf "${bold}${GRE}Script to build Code - OSS for Linux or Windows.${c0}\n" &&
	printf "${bold}${YEL}Use the --deps flag to install build dependencies.${c0}\n" &&
	printf "${bold}${YEL}Use the --linux flag to build for Linux.${c0}\n" &&
	printf "${bold}${YEL}Use the --win flag to build for Windows.${c0}\n" &&
	printf "${bold}${YEL}Use the --clean flag to remove all artifacts.\n" &&
	printf "${bold}${YEL}Use the --help flag to show this help.${c0}\n" &&
	printf "\n"
}
case $1 in
	--help) displayHelp; exit 0;;
esac

# Install prerequisites
installDeps () {
	sudo apt-get install build-essential git g++ pkg-config automake make gcc libsecret-1-dev fakeroot rpm dpkg dpkg-dev imagemagick libx11-dev libxkbfile-dev jq python3 &&
	printf "\n" &&
	printf "${bold}${YEL}It is recommended to install Nodejs via nvm.${c0}\n"
}
case $1 in
	--deps) installDeps; exit 0;;
esac

# Clean build artifacts
cleanCode () {
	printf "\n" &&
	printf "${bold}${YEL} Cleaning assets, artifacts, and build directory...${c0}\n" &&
	printf "\n" &&

	rm -r -f ./.build/* &&
	rm -r -f ./out*
}
case $1 in
	--clean) cleanCode; exit 0;;
esac

printf "\n" &&
printf "${bold}${GRE}Script to build Code - OSS for Linux or Windows.${c0}\n" &&
printf "${bold}${YEL}Use the --deps flag to install build dependencies.${c0}\n" &&
printf "${bold}${YEL}Use the --linux flag to build for Linux.${c0}\n" &&
printf "${bold}${YEL}Use the --win flag to build for Windows.${c0}\n" &&
printf "${bold}${YEL}Use the --clean flag to remove all artifacts.\n" &&
printf "${bold}${YEL}Use the --help flag to show this help.${c0}\n" &&
printf "\n" &&
tput sgr0 &&

buildLinux () {
export VSCODE_SKIP_NODE_VERSION_CHECK=1 &&
export CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export LDFLAGS="-Wl,-O3 -msse3 -s" &&

# Patch package.jsons to use Node 16
/usr/bin/find ./ \( -type d -name .git -prune -type d -name node_modules -prune \) -o -type f -name package.json -print0 | xargs -0 sed -i 's/\"\@types\/node\"\:\ \"18\.x\"/\"\@types\/node\"\:\ \"16\.x\"/g' &&

# Copy my icons over the source tree
# cp -r -v ./logos/resources/. ./resources/ &&

yarn install &&
yarn monaco-compile-check &&
yarn valid-layers-check &&
yarn gulp compile-build &&
yarn gulp compile-extension-media &&
yarn gulp compile-extensions-build &&
yarn gulp minify-vscode &&
yarn gulp vscode-linux-x64-min-ci &&
#yarn gulp vscode-linux-x64-build-deb
}
case $1 in
	--linux) buildLinux; exit 0;;
esac

buildWin () {
# Set msvs_version for node-gyp on Windows
export MSVS_VERSION="2022" &&
export GYP_MSVS_VERSION="2022" &&
set MSVS_VERSION="2022" &&
set GYP_MSVS_VERSION="2022" &&
# Don't complain about using Node 16
export VSCODE_SKIP_NODE_VERSION_CHECK=1 &&
export CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export LDFLAGS="-Wl,-O3 -msse3 -s" &&
set VSCODE_SKIP_NODE_VERSION_CHECK=1 &&
set CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
set CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
set CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
set LDFLAGS="-Wl,-O3 -msse3 -s" &&

# Patch package.jsons to use Node 16
/usr/bin/find ./ \( -type d -name .git -prune -type d -name node_modules -prune \) -o -type f -name package.json -print0 | xargs -0 sed -i 's/\"\@types\/node\"\:\ \"18\.x\"/\"\@types\/node\"\:\ \"16\.x\"/g' &&

# Copy my icons over the source tree
# cp -r -v ./logos/resources/. ./resources/ &&

yarn install &&
yarn monaco-compile-check &&
yarn valid-layers-check &&
yarn gulp compile-build &&
yarn gulp compile-extension-media &&
yarn gulp compile-extensions-build &&
yarn gulp minify-vscode &&
yarn gulp vscode-win32-x64-min-ci &&
#yarn gulp vscode-win32-x64-inno-updater &&
#yarn gulp vscode-win32-x64-system-setup &&
#yarn gulp vscode-win32-x64-user-setup
}
case $1 in
	--win) buildWin; exit 0;;
esac

exit 0
