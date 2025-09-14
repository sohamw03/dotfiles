!# /usr/bin/env bash

currdir = $(pwd)
paru -Syu \
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
hyprpaper \
swayosd-git \

sudo systemctl enable --now swayosd-libinput-backend.service

# Elephant
git clone https://github.com/abenz1267/elephant $HOME/elephant
cd $HOME/elephant/cmd/elephant
go install elephant.go
mkdir -p ~/.config/elephant/providers
cd $HOME/elephant/internal/providers/desktopapplications
go build -buildmode=plugin
cp desktopapplications.so ~/.config/elephant/providers/
rm -rf $HOME/elephant/
sudo mv $(which elephant) /usr/local/bin/

# Walker
git clone https://github.com/abenz1267/walker.git $HOME/walker
cd $HOME/walker
cargo build --release
sudo mv target/release/walker /usr/local/bin/
rm -rf $HOME/walker

cd "$(currdir)"
