#!/bin/bash
cd ./Unofficial-Spotify

if test -f ./*.snap
then
    rm ./*.snap
    rm -r ./debpkgs
    rm -r ./snap_files
else
    echo "No clean-up neccessary"
    exit
fi
