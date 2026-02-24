#!/bin/bash
# This script is intended to be used by NVIDIA-GPU Owners, you may comment the line with

# The following script is for installing Cinnamon & Services after installing base-void (glibc)

# start bash - set for root
clear
echo "Set rootshell to /bin/bash"
echo "Please give root password"
su -c "chsh -s /bin/bash root"
sleep 2

# Activate sudo
clear
echo "Activate sudo for wheel-group"
echo "Please give root password"
su -c 'echo "%wheel ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers > /dev/null'
sleep 2

# Styling
clear
echo "Setting up Lightdm/Cinnamon background image"
echo " -- Please give sudo-password -- "
sudo mkdir -p /usr/share/backgrounds/
sudo cp ~/void-cinnamon/*.jpg /usr/share/backgrounds/

# Copy automountscript for udisk2
sudo cp ~/void-cinnamon/mount_disks.sh /usr/bin/


# Check system updates
sudo xbps-install -Syu

# Activate all essential Repos
clear
echo " Activate all essential additional repos"
sudo xbps-install -y void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
sleep 2

# Update voidrepository
sudo xbps-install -Syu

# Install editor
clear
echo "Install nano..."
sudo xbps-install -y nano
sleep 1

# Network
clear
echo "Install NetworkManager"
sudo xbps-install -y NetworkManager
sudo ln -s /etc/sv/NetworkManager /var/service/
sleep 1

# dbus
clear
echo "Install dbus..."
sudo xbps-install -y dbus
sudo ln -s /etc/sv/dbus /var/service/
sleep 1

# elogind
clear
echo "Install elogind..."
sudo xbps-install -y elogind
sudo ln -s /etc/sv/elogind /var/service/
sleep 1

# Audio/bluetooth/Mixer
clear
echo "Install pipewire, wireplumber, pavucontrol, pulsemixer"
sudo xbps-install -y pipewire wireplumber pavucontrol pulsemixer libspa-bluetooth blueman bluez-cups
sleep 1

# Install NVIDIA-driver
clear
echo "Available NVIDIA drivers:"
echo "1) Latest driver"
echo "0) No Installation"
read -p "Please select a driver (1, 0 to cancel): " selection

case "$selection" in
    1)
        echo "Installing latest driver"
        sudo xbps-install -y nvidia nvidia-libs-32bit
        ;;
    0)
        echo "Setup skipped!"
        ;;
    *)
        echo "Invalid selection!"
        ;;
esac

sleep 1

# Install some Steam-related-Stuff
sudo xbps-install -y libgcc-32bit libstdc++-32bit libdrm-32bit libglvnd-32bit mesa-dri-32bit

# XORG & Cinnamon & Tools
clear
echo "Install XORG/Cinnamon-all..."
sudo xbps-install -y xorg
sudo xbps-install -y octoxbps cinnamon-all xdg-desktop-portal xdg-desktop-portal-gtk xdg-user-dirs xdg-user-dirs-gtk xdg-utils
sleep 1

# Printer support
clear
echo "Install Printer..."
sudo xbps-install -y cups cups-filters gutenprint system-config-printer
sudo ln -s /etc/sv/cupsd /var/service/
sudo xbps-install -y gnome-system-tools users-admin
sleep 1

# Filesystem
clear
echo "Installing additional tools..."
sudo xbps-install -y exfat-utils fuse-exfat gvfs-afc gvfs-mtp gvfs-smb udisks2 ntfs-3g gptfdisk bluez
# Activate bluetoothd
sudo ln -s /etc/sv/bluetoothd /var/service/
sleep 1

# Flatpak
clear
echo "Install Flatpak..."
sudo xbps-install -y flatpak
sleep 1

# Fonts
clear
echo "Install Fonts..."
sudo xbps-install -y noto-fonts-cjk noto-fonts-emoji noto-fonts-ttf noto-fonts-ttf-extra
sleep 1

# Software
clear
echo "Install Software..."
sudo xbps-install -y firefox gnome-terminal
sleep 1
# Create a script that runs gsettings after login
echo "Creating autostart script for cinnamon theme settings..."
cat <<EOL > /home/$USER/set-cinnamon-theme.sh
#!/bin/bash
# Set the desired Cinnamon theme & Italian keyboard layout
gsettings set org.cinnamon.desktop.interface icon-theme Arc
gsettings set org.cinnamon.desktop.interface gtk-theme Arc-Dark
gsettings set org.cinnamon.theme name Arc-Dark
gsettings set org.cinnamon.desktop.input-sources sources "[('xkb', 'it')]"
gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 11'
gsettings set org.cinnamon.desktop.background picture-uri 'file:///usr/share/backgrounds/cinnamon_background.jpg'


# Delete the autostart entry after the first execution
rm -f ~/.config/autostart/set-cinnamon-theme.desktop

echo "Cinnamon themes have been set and the autostart entry has been removed."
EOL

chmod +x /home/$USER/set-cinnamon-theme.sh

# Create the autorun file that executes the script
mkdir -p ~/.config/autostart
cat <<EOL > ~/.config/autostart/set-cinnamon-theme.desktop
[Desktop Entry]
Type=Application
Exec=/home/$USER/set-cinnamon-theme.sh
Name=Set Cinnamon Theme
Comment=Set the default Cinnamon theme after login
X-GNOME-Autostart-enabled=true
EOL

# create .desktopfile for octoxbps-notifier
cat > ~/.config/autostart/octoxbps-notifier.desktop <<EOL
[Desktop Entry]
Type=Application
Exec=/bin/octoxbps-notifier
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=OctoXBPS Notifier
Comment=Start OctoXBPS Update Notifier automatically
EOL

# Create .desktopfile for italian-X11-keyboard
# Please remove this autostart-entry if you would like to set the keyboardlayout directly in Cinnamon
cat > ~/.config/autostart/x11kb-german.desktop <<EOL
[Desktop Entry]
Type=Application
Exec=/usr/bin/setxkbmap it
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=X11-KB-Italian
Comment=Enable Italian keyboard under X11
EOL

# Create .desktopfile for auto-mount script (for udisks2)
# Please remove this autostart-entry if you would like to set the keyboard layout directly in Cinnamon
cat > ~/.config/autostart/automount-udisks2.desktop <<EOL
[Desktop Entry]
Type=Application
Exec=/usr/bin/mount_disks.sh 
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=X11-automount-udisks2
Comment=Automount script for udisks2
EOL


# Login manager
clear
echo "Install LightDM..."
sudo xbps-install -y lightdm lightdm-gtk-greeter
sudo ln -s /etc/sv/lightdm/ /var/service/
sleep 1

# Cinnamon-Themes
clear
echo "Install ArcTheme / Arc-icons..."
sudo xbps-install -y arc-icon-theme arc-theme
sleep 1

# Add the desired settings to the LightDM configuration
echo "theme-name=Arc-Dark" | sudo tee -a /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null
echo "icon-theme-name=Arc" | sudo tee -a /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null
echo "background=/usr/share/backgrounds/lightdmbackground.jpg" | sudo tee -a /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null

# Setup Autostart - pipewire & wireplumber

sudo mkdir -p /etc/pipewire/pipewire.conf.d

sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

sudo ln -s /usr/share/applications/pipewire.desktop /etc/xdg/autostart/
sleep 1
clear
# Activate Italian keyboard for X11
echo "it_IT" > "$HOME/.config/user-dirs.locale"

# Setup automount for ssds/hdds - without fstab
sudo cp ~/void/10-mount-drives.rules /etc/polkit-1/rules.d/
clear
echo "Setup finished - please reboot"
