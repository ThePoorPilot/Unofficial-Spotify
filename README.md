# Unofficial-Spotify
Unofficial Decompressed Spotify Debian/Arch Binaries from the Flatpak Spotify Package.

Currently, the only way to get the latest version of Spotify(1.1.46.916.g416cacf1) is through either a Flatpak or Snap Package. The latest spotify binary available from the debian repository is 1.1.42.622.

When I investigated the Flatpak files I realized they were pretty much all the same files as the older binaries. As a test, I mixed the files from the old spotify package(debian "apt" based package) with the files from the flatpak file. I replaced almost all files with files from flatpak files. The only files I did not replace were icon files and the changelong.

Anyways, I gave it a test(on my Arch-based system(package still based on debian package) and it worked!
In the Spotify about dialogue I now see 1.1.46.916.g416cacf1, the latest version!

My hope with this repo is that someone who knows how to deal with packages can produce a "Unoffical-Spotify" package(for Debian/Arch) that allows people who don't want to use Snap or Flatpak to keep updated. Either that, or the Spotify developers start updating the debian packages again.
