#!/bin/bash

#remove any old data if it is there
rm *.snap
rm -r ./snap_files
rm -r ./debpkgs/spotify-unofficial_latest_amd64
rm ./spotify-unofficial_latest_amd64.deb

mkdir ./debpkgs/
mkdir ./debpkgs/spotify-unofficial_latest_amd64
mkdir ./snap_files

echo "Downloading snap package data..."
wget https://api.snapcraft.io/api/v1/snaps/download/pOBIoZ2LrCB3rDohMxoYGnbN14EHOgD7_43.snap

cd snap_files
echo "Decompressing .snap package..."
unsquashfs ../pOBIoZ2LrCB3rDohMxoYGnbN14EHOgD7_43.snap

echo "Copying files for package..."
cd ../
mkdir ./debpkgs/spotify-unofficial_latest_amd64/usr
mkdir ./debpkgs/spotify-unofficial_latest_amd64/usr/share
mkdir ./debpkgs/spotify-unofficial_latest_amd64/usr/bin
mkdir ./debpkgs/spotify-unofficial_latest_amd64/usr/share/spotify/
mkdir ./debpkgs/spotify-unofficial_latest_amd64/usr/share/doc
cp -r ./necessary_files/DEBIAN/ ./debpkgs/spotify-unofficial_latest_amd64
mv ./snap_files/squashfs-root/usr/share/spotify/ ./debpkgs/spotify-unofficial_latest_amd64/usr/share/
mv ./snap_files/squashfs-root/usr/share/doc/spotify-client/ ./debpkgs/spotify-unofficial_latest_amd64/usr/share/doc/spotify-client
# Make Symbolic Link in /usr/bin
cd ./debpkgs/spotify-unofficial_latest_amd64/usr/bin
ln -s ../share/spotify/spotify spotify

echo "Building Package..."
#A little ridiculous, but had to go pretty deep to generate proper symlink file
cd ../
cd ../
cd ../
cd ../
#fix permissions
chmod 755 ./debpkgs/spotify-unofficial_latest_amd64/DEBIAN/postinst
chmod 755 ./debpkgs/spotify-unofficial_latest_amd64/DEBIAN/prerm
dpkg --build ./debpkgs/spotify-unofficial_latest_amd64/
mv ./debpkgs/spotify-unofficial_latest_amd64.deb ./
