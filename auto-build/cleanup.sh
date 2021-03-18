#!/bin/bash
cd ./Unofficial-Spotify

if test -f ./*.snap
    rm ./*.snap
    rm -r ./debpkgs
    rm -r ./snap_files
else
    echo "No clean-up neccessary"
    exit
fi
