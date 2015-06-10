#!/bin/bash
echo 'installing arduinostudio to your ~/.local directory'

curDir=$(pwd)

mkdir -p ~/.local/share/applications
mkdir -p ~/.local/bin

# Setup our arduinostudio.desktop file.
cp arduinostudio.desktop temp.desktop
execPath="$curDir/arduinostudio"
iconPath="$curDir/arduinostudio.svg"

sed -i 's|Exec=arduinostudio|Exec='$execPath'|g' temp.desktop
sed -i 's|Icon=arduinostudio|Icon='$iconPath'|g' temp.desktop
cp temp.desktop ~/.local/share/applications/arduinostudio.desktop
rm temp.desktop

# Run xdg-desktop-menu to register the .desktop file.
# This is for Unity's benefit: Gnome 3 and KDE 4 both watch ~/.local/share/applications and install .desktop files automatically.
# Copy-pasta this straight from the .deb's postinst script.
XDG_DESKTOP_MENU="`which xdg-desktop-menu 2> /dev/null`"
if [ ! -x "$XDG_DESKTOP_MENU" ]; then
  echo "Error: Could not find xdg-desktop-menu" >&2
  exit 1
fi
"$XDG_DESKTOP_MENU" install ~/.local/share/applications/arduinostudio.desktop --novendor

# Symlink arduinostudio executable to our current location... where-ever that is.
rm -f ~/.local/bin/arduinostudio
ln -s $execPath ~/.local/bin/arduinostudio

# Try to symlink libudev.so.0 to the current directory.
# Gratefully borrowed from https://github.com/rogerwang/node-webkit/wiki/The-solution-of-lacking-libudev.so.0
paths=(
  "/lib/x86_64-linux-gnu/libudev.so.1" # Ubuntu, Xubuntu, Mint
  "/usr/lib64/libudev.so.1" # SUSE, Fedora
  "/usr/lib/libudev.so.1" # Arch, Fedora 32bit
  "/lib/i386-linux-gnu/libudev.so.1" # Ubuntu 32bit
)
for i in "${paths[@]}"
do
  if [ -f $i ]
  then
    ln -sf "$i" $curDir/libudev.so.0
    break
  fi
done

echo 'installed arduinostudio to ~/.local'
