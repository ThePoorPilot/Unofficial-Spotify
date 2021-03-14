if [ -x /usr/bin/update-desktop-database ]; then
  /usr/bin/update-desktop-database -q usr/share/applications > /dev/null 2>&1
fi

if [ -e usr/share/icons/hicolor/icon-theme.cache ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
  	/usr/bin/gtk-update-icon-cache -t -f -q usr/share/icons/hicolor >/dev/null 2>&1
  fi
fi

( cd usr/bin ; rm -rf spotify )
( cd usr/bin ; ln -sf ../share/spotify/spotify spotify )
