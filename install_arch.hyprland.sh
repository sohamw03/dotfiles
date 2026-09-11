#! /usr/bin/env bash

currdir=$(pwd)
paru -Syu --noconfirm --needed \
    hyprland \
    xdg-desktop-portal-hyprland \
    sddm \
    kitty \
    ghostty \
    polkit \
    rtkit \
    hyprpolkitagent \
    uwsm-git \
    hypridle \
    hyprlock \
    hyprpaper \
    hyprsunset \
    hyprshot \
    hyprshade \
    hyprshutdown \
    swayosd-git \
    pipewire \
    wireplumber \
    pipewire-pulse \
    pipewire-alsa \
    pavucontrol \
    sddm-silent-theme \
    mako \
    cliphist \
    nwg-look \
    gnome-themes-extra \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gnome \
    nautilus \
    vicinae-bin \
    wiremix \
    pamixer \
    gazelle-tui \
    loupe \
    proton-vpn-cli \
    google-chrome \
    brave-bin \
    ttf-hack-nerd \
    ttf-ms-fonts \
    noto-fonts \
    noto-fonts-extra \
    noto-fonts-emoji \
    wlsunset \
    qt5-wayland \
    qt6-wayland \
    noctalia-shell \
    brightnessctl \
    imagemagick \
    cava \
    ttf-material-design-iconic-font \
    plymouth \
    visual-studio-code-bin \
    ttf-roboto \
    lucidglyph \
    easyeffects \
    lsp-plugins-lv2 \
    calf \
    xdotool \
    hyprpicker \
    tensaku

# proton-vpn-gtk-app \
# waybar

paru -S gnome-bluetooth --nocheck --noconfirm
paru -S blueberry-wayland --noconfirm

sudo systemctl enable --now swayosd-libinput-backend.service
sudo systemctl enable sddm
sudo systemctl --user enable --now pipewire wireplumber pipewire-pulse
sudo systemctl --user enable --now hyprpolkitagent.service
# sudo systemctl --user enable --now waybar.service
# sudo systemctl --user enable --now hyprpaper.service

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
# git clone https://github.com/lr-tech/rofi-themes-collection.git $HOME/CODE/rofi-themes-collection
# cd $HOME/CODE/rofi-themes-collection
# mkdir -p $HOME/.local/share/rofi/themes/
# cp -r themes/* $HOME/.local/share/rofi/themes/

# SDDM Silent theme (idempotent: overwrite, not append)
sudo tee /etc/sddm.conf >/dev/null <<'EOF'
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard,LIBVA_DRIVER_NAME=,QT_MULTIMEDIA_PREFERRED_PLUGINS=

[Theme]
Current=silent
EOF

# Plymouth / SDDM seamless boot (ghost GRUB fix)
# Step 1: hexagon_alt is transparent by default, so GRUB fb shows through.
# Paint opaque black background behind the animation.
sudo python3 - <<'PY'
from pathlib import Path
p = Path("/usr/share/plymouth/themes/hexagon_alt/hexagon_alt.script")
t = p.read_text()
opaque = "Window.SetBackgroundTopColor(0, 0, 0);\nWindow.SetBackgroundBottomColor(0, 0, 0);"
if "SetBackgroundTopColor" not in t:
    t = t.replace(
        "screen.half.h = Window.GetHeight(0) / 2;",
        "screen.half.h = Window.GetHeight(0) / 2;\n\n// Opaque background so GRUB framebuffer ghost can't show through\n" + opaque,
        1,
    )
    p.write_text(t)
    print("patched hexagon_alt.script to opaque black")
else:
    print("hexagon_alt.script already opaque")
PY

# Step 2: show splash immediately instead of ~5s delay.
# Without this plymouth-start waits and GRUB fb sits on screen.
sudo python3 - <<'PY'
from pathlib import Path
p = Path("/etc/plymouth/plymouthd.conf")
t = p.read_text() if p.exists() else "[Daemon]\n"
if "ShowDelay" not in t:
    if "[Daemon]" in t:
        t = t.replace("[Daemon]", "[Daemon]\nShowDelay=0", 1)
    else:
        t = "[Daemon]\nShowDelay=0\n" + t
    p.write_text(t)
    print("set ShowDelay=0")
else:
    print("ShowDelay already set")
PY

# Step 3: let SDDM start while Plymouth still holds, keep last frame.
# Default is sddm After plymouth-quit, so screen is uncovered during X startup.
# Drop-in After= reset doesn't work on systemd 261 (verified via systemctl show),
# so use a full override for sddm.service without plymouth-quit in After.
# Also make plymouth-quit wait for sddm + retain splash.
sudo rm -rf /etc/systemd/system/sddm.service.d
sudo tee /etc/systemd/system/sddm.service >/dev/null <<'EOF'
[Unit]
Description=Simple Desktop Display Manager
Documentation=man:sddm(1) man:sddm.conf(5)
Conflicts=getty@tty1.service
After=systemd-user-sessions.service getty@tty1.service systemd-logind.service
PartOf=graphical.target
StartLimitIntervalSec=30
StartLimitBurst=2

[Service]
ExecStart=/usr/bin/sddm
Restart=always

[Install]
Alias=display-manager.service
EOF
sudo mkdir -p /etc/systemd/system/plymouth-quit.service.d
sudo tee /etc/systemd/system/plymouth-quit.service.d/wait-for-sddm.conf >/dev/null <<'EOF'
[Unit]
After=sddm.service
[Service]
ExecStart=
ExecStart=-/usr/bin/plymouth quit --retain-splash
EOF
sudo systemctl daemon-reload

# Step 4: hold Plymouth until greeter actually appears, not just sddm process start.
# sddm process starts ~28s but greeter paints ~59s. Poll for sddm-greeter then quit.
sudo tee /usr/local/bin/plymouth-quit-after-greeter.sh >/dev/null <<'EOF'
#!/bin/sh
# Wait max ~60s for sddm-greeter, then quit retaining last frame
for i in $(seq 1 120); do
  if pgrep -f sddm-greeter-qt6 >/dev/null 2>&1; then
    sleep 3
    break
  fi
  sleep 0.5
done
exec /usr/bin/plymouth quit --retain-splash
EOF
sudo chmod +x /usr/local/bin/plymouth-quit-after-greeter.sh
sudo tee /etc/systemd/system/plymouth-quit.service.d/wait-for-sddm.conf >/dev/null <<'EOF'
[Unit]
After=sddm.service
[Service]
ExecStart=
ExecStart=-/usr/local/bin/plymouth-quit-after-greeter.sh
EOF
sudo systemctl daemon-reload

# Step 5: rebuild initramfs so opaque theme + ShowDelay ship in early boot,
# and pin GRUB to panel native res to avoid mode-switch flash.
# plymouth hook already includes hexagon_alt + plymouthd.conf in the image.
sudo sed -i 's/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080/' /etc/default/grub
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

# GRUB: keep 'Windows 11' label + icon while leaving os-prober enabled.
# dedsec/icons/ only has windows11.png, so the os-prober default name
# ('Windows Boot Manager ...') misses the icon. Rename after every regen
# and add --class windows11 so the icon matches deterministically.
# NOTE: re-run the sed after every grub-mkconfig (kernel/grub updates).
sudo sed -i 's/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo rm -f /etc/grub.d/31_windows11
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo sed -i "s/Windows Boot Manager (on \\/dev\\/nvme0n1p1)/Windows 11/; s/menuentry 'Windows 11' --class windows --class os/menuentry 'Windows 11' --class windows11 --class windows --class os/" /boot/grub/grub.cfg
grep -n "menuentry" /boot/grub/grub.cfg

cd "$currdir"
