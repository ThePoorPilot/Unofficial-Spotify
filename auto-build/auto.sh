#!/bin/bash

#dependencies: jq, squashfs-tools, wget, git, curl, github-cli, dpkg
#variables taken from https://github.com/megamaced/spotify-easyrpm/
V_HTTP_REPO="$(curl -s -H 'Snap-Device-Series: 16' http://api.snapcraft.io/v2/snaps/info/spotify | jq -r '."channel-map"[] | select(.channel.name=='\"stable\"') | .download.url')"
V_HTTP_VERSION="$(curl -s -H 'Snap-Device-Series: 16' http://api.snapcraft.io/v2/snaps/info/spotify | jq -r '."channel-map"[] | select(.channel.name=='\"stable\"') | .version')" 

#Check if snap is up
SNAP_STATUS="$(curl -s -I http://api.snapcraft.io/ | grep -c '200 OK')"

if [ "$SNAP_STATUS" == "1" ]
then
    echo "Snap store is online"
else
    echo "Snap Store is offline, canceling build"
    exit
fi
#Check if there is a new package
if [ "$V_HTTP_VERSION" == "1.1.55.498.gf9a83c60" ]
then
    echo "no need to re-build. Try again in another hour!"
    exit
else
    #replace version number in checking
    sed -i 's/1.1.55.498.gf9a83c60/'"$V_HTTP_VERSION"'/g' ./auto.sh
    echo 'New Package Found! Version:'"$V_HTTP_VERSION"
fi

#remove any old data if it is there
rm ./*.snap
rm -r ./snap_files
rm -r ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64
rm ./spotify-unofficial_"$V_HTTP_VERSION"_amd64.deb

mkdir ./debpkgs/
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64
mkdir ./snap_files

echo ""
echo "Downloading snap package data..."
echo ""
wget -q $V_HTTP_REPO

cd snap_files
echo ""
echo "Decompressing .snap package..."
echo ""
unsquashfs ../*.snap

echo ""
echo "Copying files for package..."
echo ""
cd ../
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/share
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/bin
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/share/spotify/
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/share/doc
mkdir ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/DEBIAN
mv ./snap_files/squashfs-root/usr/share/spotify/ ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/share/
mv ./snap_files/squashfs-root/usr/share/doc/spotify-client/ ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/share/doc/spotify-client

echo ""
echo "Creating control files..."
echo ""
#control files taken from last Debian Package provided by spotify. They own the copyright to these files
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
#create postinst file
cat << EOF > ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/DEBIAN/postinst
#!/bin/sh
#
# Copyright (c) 2015 Spotify AB
#
# This script registers menus and icons. It should be run from the top-level
# folder of the uncompressed Spotify distribution. Since this script is also run
# as a post-install task for the debian package, it will attempt to run relative
# to /usr/share/spotify if this path is available.

spotifyPath=\$PWD
if [ -e /usr/share/spotify ]; then
  spotifyPath=/usr/share/spotify
fi

# Add icons to the system icon folders
XDG_ICON_RESOURCE="\$(command -v xdg-icon-resource 2> /dev/null)"
if [ ! -x "\$XDG_ICON_RESOURCE" ]; then
  echo "Error: Could not find xdg-icon-resource" >&2
  exit 1
fi

for icon in "\$spotifyPath"/icons/spotify-linux-*.png; do
  [ -e "\$icon" ] || break
  size="\${icon##*/spotify-linux-}"
  "\$XDG_ICON_RESOURCE" install --noupdate --size "\${size%.png}" "\$icon" "spotify-client"
done
"\$XDG_ICON_RESOURCE" forceupdate

# Add an entry to the system menu
XDG_DESKTOP_MENU="\$(command -v xdg-desktop-menu 2> /dev/null)"
UPDATE_MENUS="\$(command -v update-menus 2> /dev/null)"
if [ ! -x "\$XDG_DESKTOP_MENU" ]; then
  echo "Error: Could not find xdg-desktop-menu" >&2
  exit 1
fi

# It seems the desktop file has to match the MPris name. We don't want to
# change that, so we use --novendor here instead.
"\$XDG_DESKTOP_MENU" install --novendor "\$spotifyPath/spotify.desktop"
if [ -x "\$UPDATE_MENUS" ]; then
  "\$UPDATE_MENUS"
fi

# Add Spotify repository APT keys
APT_TRUSTED=/etc/apt/trusted.gpg.d
if [ -d \$APT_TRUSTED ]; then
    for keyPath in "\$spotifyPath"/apt-keys/*.gpg; do
      keyFileName=\$(basename "\$keyPath")
      if [ ! -e "\$APT_TRUSTED/\$keyFileName" ]; then
          cp "\$keyPath" "\$APT_TRUSTED/"
          chmod 644 "\$APT_TRUSTED/\$keyFileName"
      fi
    done
fi

# Add Spotify repository nondestructively
# Let users opt-out of adding a repository with:
# sudo touch /etc/apt/sources.list.d/spotify.list
#SOURCE="/etc/apt/sources.list.d/spotify.list"
#if [ ! -e "\$SOURCE" ]; then
    # Check if there is already an active source configuration
    # and only add one if we can't find one
#    if ! grep -v -E '^\s*#' /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null | \'
#      grep -q -E 'deb\s+.*https?://repository(-origin)?.spotify.com\s+(stable|1.1.46.916.g416cacf1ing)\s+non-free'
#    then
#        tee "\$SOURCE" >/dev/null 2>&1 <<EOF
#deb http://repository.spotify.com stable non-free
#EOF
#    fi
#fi

EOF
#create prerm file
cat << EOF > ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/DEBIAN/prerm
#!/bin/sh
#
# Copyright (c) 2015 Spotify AB
#
# This script unregisters menus and icons. It should be run from the top-level
# folder of the uncompressed Spotify distribution.

spotifyPath=\$PWD
if [ -e /usr/share/spotify ]; then
  spotifyPath=/usr/share/spotify
fi

# Remove icons from the system icon folders
XDG_ICON_RESOURCE="$(command -v xdg-icon-resource 2> /dev/null)"
if [ ! -x "\$XDG_ICON_RESOURCE" ]; then
  echo "Error: Could not find xdg-icon-resource" >&2
  exit 1
fi

for icon in "\$spotifyPath"/icons/spotify-linux-*.png; do
  [ -e "\$icon" ] || break
  size="\${icon##*/spotify-linux-}"
  "\$XDG_ICON_RESOURCE" uninstall --noupdate --size "\${size%.png}" "\$icon" "spotify-client"
done
"\$XDG_ICON_RESOURCE" forceupdate

# Remove the entry from the system menu
XDG_DESKTOP_MENU="\$(command -v xdg-desktop-menu 2> /dev/null)"
UPDATE_MENUS="\$(command -v update-menus 2> /dev/null)"
if [ ! -x "\$XDG_DESKTOP_MENU" ]; then
  echo "Error: Could not find xdg-desktop-menu" >&2
  exit 1
fi

"\$XDG_DESKTOP_MENU" uninstall --novendor "spotify.desktop"
if [ -x "\$UPDATE_MENUS" ]; then
  "\$UPDATE_MENUS"
fi

EOF

# Create symbolic link in /usr/bin
cd ./debpkgs/spotify-unofficial_"$V_HTTP_VERSION"_amd64/usr/bin
ln -s ../share/spotify/spotify spotify

echo ""
echo "Building Package..."
echo ""
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
echo "spotify-unofficial package created in Build Directory"

cat << EOF > ../release_notes.md
Auto-built package
$V_HTTP_VERSION stable
EOF

#Size check in case of errors in build
SIZE_CHECK=$(wc -c ./*.deb | awk '{print $1}')
 
if [ "$SIZE_CHECK" -gt 10000000 ]
then
    gh auth login --with-token < ../token.txt
    gh release create -R github.com/ThePoorPilot/Unofficial-Spotify "$V_HTTP_VERSION" ./*.deb -F ../release_notes.md  -t "Stable $V_HTTP_VERSION"
else
    rm ./*.deb
    echo ".deb file is too small, removing and not creating a release"
fi
