#!/bin/bash

PASSWORD="insert_password_here"
cd ./Unofficial-Spotify

if test -f ./*.deb
then
    echo "Pushing revised auto.sh to GitHub..."
    rm ./*.deb
    git config --global user.name "ThePoorPilot"
    git config --global user.email "ios8jailbreakpangu@gmail.com"
    git add .
    git commit -m 'changed version number in build checking'
    git push https://ThePoorPilot:"$PASSWORD"@github.com/ThePoorPilot/Unofficial-Spotify.git 
else
    echo "There isn't a new version, no need to push!"
    exit
fi
