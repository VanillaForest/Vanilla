#!/bin/sh

# Vanilla complete linux distro installer
# you may tweak the config in this file

# Clean old rootfs
rm -rf rootfs/
rm -rf src/

# Set global variables
export CC='musl-gcc'
export CFLAGS='-Os -s'
export LDFLAGS=
export THREADS=3
export BASE="$PWD"
export ROOTFS="$PWD/rootfs"

# Setup rootfs skelly
mkdir -p rootfs/bin
mkdir -p rootfs/lib
mkdir -p rootfs/share
mkdir -p rootfs/include

# Utils

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

# Parse package database
for orchid in $(find ./orchids -type f)
do 
	# Downloading orchid name source
	name=$(basename $orchid)
	url=$(cat $orchid | grep ^\# | tr -d '#')
	echo " * Building  $name from $url "
	fetch $url $name
	# Building it
	cd $BASE/src/$name
	sh $BASE/$orchid
	cd $BASE
done 

# Cleaning up buid utils
rm -rf $BASE/src

echo "Vanilla done building ^.^"
