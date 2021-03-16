#!/bin/bash

#variables taken from https://github.com/megamaced/spotify-easyrpm/
V_HTTP_REPO="$(curl -s -H 'Snap-Device-Series: 16' http://api.snapcraft.io/v2/snaps/info/spotify | jq -r '."channel-map"[] | select(.channel.name=='\"stable\"') | .download.url')"
V_HTTP_VERSION="$(curl -s -H 'Snap-Device-Series: 16' http://api.snapcraft.io/v2/snaps/info/spotify | jq -r '."channel-map"[] | select(.channel.name=='\"stable\"') | .version')" 

#Check is snap is up
SNAP_STATUS="$(curl -s -I http://api.snapcraft.io/ | grep -c '200 OK')"

if [ "$SNAP_STATUS" == "1" ]
then
    echo "Snap store is online"
else
    echo "Snap Store is offline, canceling build"
    exit
fi

#remove any old data if it is there
rm *.snap
rm -r ./snap_files
rm -r ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64
rm ./spotify-unofficial_"$V_HTTP_VERSION"_amd64.deb

mkdir ./debpkgs/
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64
mkdir ./snap_files

echo "Downloading snap package data..."
wget $V_HTTP_REPO

cd snap_files
echo "Decompressing .snap package..."
unsquashfs ../*.snap

echo "Copying files for package..."
cd ../
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/share
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/bin
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/share/spotify/
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/share/doc
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/DEBIAN
mv ./snap_files/squashfs-root/usr/share/spotify/ ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/share/
mv ./snap_files/squashfs-root/usr/share/doc/spotify-client/ ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/share/doc/spotify-client
cp -r ./control_files/* ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/DEBIAN
#create control file with correct version number
cat << EOF > ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/DEBIAN/control
Package: spotify-unofficial
Version: 1:$V_HTTP_VERSION
License: https://www.spotify.com/legal/end-user-agreement
Vendor: Spotify AB
Architecture: amd64
Maintainer: Michael Monaco <thepoorpilot@gmail.com>
Depends: libasound2, libatk-bridge2.0-0, libatomic1, libcurl3-gnutls, libgbm1, libgconf-2-4, libglib2.0-0, libgtk2.0-0, libnss3, libssl1.1 | libssl1.0.2 | libssl1.0.1 | libssl1.0.0, libxss1, libxtst6, xdg-utils
Recommends: libavcodec57 | libavcodec-extra57 | libavcodec-ffmpeg56 | libavcodec-ffmpeg-extra56 | libavcodec54 | libavcodec-extra-54, libavformat57 | libavformat-ffmpeg56 | libavformat54
Suggests: libnotify4
Section: sound
Priority: extra
Homepage: https://www.spotify.com
Description: Spotify streaming music client
EOF

# Make Symbolic Link in /usr/bin
cd ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/bin
ln -s ../share/spotify/spotify spotify

echo "Building Package..."
#A little ridiculous, but had to go pretty deep to generate proper symlink file
cd ../
cd ../
cd ../
cd ../
#fix permissions
chmod 755 ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/DEBIAN/postinst
chmod 755 ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/DEBIAN/prerm
dpkg --build ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/
mv ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64.deb ./
echo "Spotify-unofficial package created in Build Directory"
