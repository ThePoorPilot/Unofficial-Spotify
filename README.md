# Unofficial-Spotify

Currently, the only way to get the latest version of Spotify(1.1.46.916.g416cacf1) is through either a Flatpak or Snap Package. The latest spotify binary available from the debian repository is 1.1.42.622.

When I investigated the Snap files I realized they were pretty much all the same files as the older binaries. As a test, I mixed the files from the old spotify package(debian "apt" based package) with the files from the snap package.

I gave it a test(on my Arch-based system(package still based on debian package)) and it worked!
In the Spotify about dialogue I now see 1.1.46.916.g416cacf1, the latest version!

![Screenshot](https://raw.githubusercontent.com/ThePoorPilot/Unofficial-Spotify/main/Screenshot.png)

BIG NOTE: if you want to mess around with these binaries on your system extract the ".so_files" tar.gz file in their respective folders. I had to compress them to comply with the github file size limit.

## Installation
Make sure to remove any current "spotify" packages installed. It is also recomended to remove the spotify repository from your system(mainly applies to Debian)

Download your preferred package from releases here: https://github.com/ThePoorPilot/Unofficial-Spotify/releases/

Install using your package manager or a GUI software installer.

For Fedora/RHEL, use https://negativo17.org/spotify-client/.

For RPM-based distros(primarily OpenSuse), this is also another option: https://github.com/megamaced/spotify-easyrpm. The dev has recently switched it to be snap based.

Alternatively, you can try to create your own packages using the decompressed binaries on this repository. If you decide to take this route, I assume you have experience. As such, I will not provide support for installation in this fashion.

## Disclaimer
As always, there is no copyright infringement itended here. This repository exposes no source code and all files are publicly available through spotify packages(debian and snap).

There are some minor modifications made(namely to the postinst in Debian). Such modifications only comment out parts of spotify code, which is the best I could do to respect copyright and retain functionality.
