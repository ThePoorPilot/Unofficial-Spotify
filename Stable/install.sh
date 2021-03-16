#!/bin/bash
./build.sh
#installing
V_HTTP_VERSION="$(curl -s -H 'Snap-Device-Series: 16' http://api.snapcraft.io/v2/snaps/info/spotify | jq -r '."channel-map"[] | select(.channel.name=='\"stable\"') | .version')" 
echo "Installing..."
sudo dpkg -i ./spotify-unofficial_"$V_HTTP_VERSION"_amd64.deb
