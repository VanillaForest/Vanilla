#!/bin/sh

# Vanilla complete linux distro installer
# you may tweak the config in this file

# Clean old rootfs
rm -rf rootfs/
rm -rf src/
rm -rf vanilla-log

# Set global variables
export CC='musl-gcc'
export CFLAGS='-Os -s'
export LDFLAGS=
export THREADS=3
export BASE="$PWD"
export ROOTFS="$PWD/rootfs"
export LOG_FILE="vanilla-log"

# Setup rootfs skelly
mkdir -p $ROOTFS/bin
mkdir -p $ROOTFS/lib
mkdir -p $ROOTFS/share
mkdir -p $ROOTFS/include

# Setup logging system

# Close STDOUT & STDEER file descriptor
#exec 1<&-
#exec 2<&-
# Open STDOUT as $LOG_FILE file for read and write.
#exec 1<>$LOG_FILE
# Redirect STDERR to STDOUT
#exec 2>&1

# Utils

# Colors
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
reset="\e[0m"

# Download a tarball from $1 and extract it in src/$2
fetch() {
	tarname=$(basename $1)
	# Allocate tmpdir
	tmpdir=$(mktemp -d)
	tarball="$tmpdir/$tarname"
	# Fetch the tarball
	wget $1 -O $tarball
	# Extract it
	tar xf $tarball -C $tmpdir
	mkdir -p "src/$2"
	# Copy it to src/$2
	cp -R $(ls -d $tmpdir/*/*) "src/$2"
	rm -rf $tmpdir
}

flourish() {
	# Set package info
	local orchid=$BASE/orchids/$1
	local name=$1
	# Recursivly install dependencies
	for dep in $(cat $orchid | grep ^\#deps | sed 's/#deps://g')
	do
	   flourish $(basename $dep)
	done
	# Get url
	local url=$(cat $orchid | grep ^\#url | sed 's/#url://g')
	echo -e "$blue *$green Building $red$name$green from$red$url$reset" > /dev/tty
	# Dowload sources
	fetch $url $name
	# Building it
	cd $BASE/src/$name
	sh $orchid 
	cd $BASE
}

# Install base packages
flourish busybox

# Cleaning up buid utils
rm -rf $BASE/src

echo "Vanilla done building ^.^"
