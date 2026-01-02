#! /usr/bin/env bash

currdir=$(pwd)
paru -Syu --noconfirm \
    hyprland \
    xdg-desktop-portal-hyprland \
    sddm \
    waybar \
    kitty \
    ghostty \
    polkit \
    rtkit \
    hyprpolkitagent \
    uwsm-git \
    hypridle \
    hyprlock \
    hyprpaper \
    swayosd-git \
    pipewire \
    wireplumber \
    pipewire-pulse \
    pipewire-alsa \
    sddm-silent-theme \
    mako \
    cliphist \
    nwg-look \
    gnome-themes-extra \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-hyprland \
    rofi-wayland \
    rofi-calc \
    wiremix \
    pamixer

sudo systemctl enable --now swayosd-libinput-backend.service
sudo systemctl --user enable --now pipewire wireplumber pipewire-pulse
sudo systemctl --user enable --now hyprpolkitagent.service

# Elephant
# git clone https://github.com/abenz1267/elephant $HOME/elephant
# cd $HOME/elephant/cmd/elephant
# go install elephant.go
# mkdir -p ~/.config/elephant/providers
# cd $HOME/elephant/internal/providers/desktopapplications
# go build -buildmode=plugin
# cp desktopapplications.so ~/.config/elephant/providers/
# rm -rf $HOME/elephant/
# sudo mv $(which elephant) /usr/local/bin/

# Rofi
git clone https://github.com/lr-tech/rofi-themes-collection.git $HOME/CODE/rofi-themes-collection
cd $HOME/CODE/rofi-themes-collection
mkdir -p $HOME/.local/share/rofi/themes/
cp -r themes/* $HOME/.local/share/rofi/themes/

# SDDM Silent theme
sudo tee -a /etc/sddm.conf <<'EOF'
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard,LIBVA_DRIVER_NAME=,QT_MULTIMEDIA_PREFERRED_PLUGINS=

[Theme]
Current=silent
EOF

cd "$(currdir)"
