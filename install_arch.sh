#!/bin/bash

# Exit if run as root
if [ "$EUID" -eq 0 ]; then
  echo "Please do not run this script as root. Run it as a regular user with sudo privileges."
  exit 1
fi

# --- User Setup ---
# The following commands should be run as root to create a new user and install sudo.
# pacman -Syu --noconfirm sudo
# useradd -m soham
# echo "soham:soham" | chpasswd
# usermod -aG wheel soham
# sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^# //g' /etc/sudoers
# sed -i '/NoProgressBar/s/^/#/g' /etc/pacman.conf
# pacman -Syu git --noconfirm
# cd /home/soham/ && git clone https://github.com/sohamw03/dotfiles

# This script installs the tools and configurations from the dotfiles.

cd /home/soham/

# --- Install Paru (AUR Helper) ---
sudo pacman -S --needed --noconfirm base-devel git
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ..
rm -rf paru

# --- Package Manager Installations (with Paru) ---
paru -S --noconfirm \
fzf \
tmux \
lazygit \
uv \
zoxide \
ripgrep \
unzip \
lua \
wget \
git-delta \
eza \
mise \
oh-my-posh-bin \
neovim \
less \
bun-bin \
git \
fd \
htop \
btop \
zsh \
zsh_autosuggestions \
yazi \
vlc \
vlc-plugins-all \
github-cli \
tlrc

# --- Locale Generation ---
echo "Generating en_US.UTF-8 locale..."
sudo sed -i '/^#en_US.UTF-8/s/^#//' /etc/locale.gen
sudo locale-gen

# --- Tmux Plugin Manager (TPM) ---
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# --- Go (via mise) ---
mise use -g python@3.12 node@24 go@latest gemini-cli@latest

# --- Neovim Configuration ---
echo "Installing Neovim configuration..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
git clone https://github.com/sohamw03/neovim $HOME/dotfiles/arch.config/nvim

# Remove existing config if it exists
if [ -d "$NVIM_CONFIG_DIR" ]; then
    echo "Existing Neovim config found. Removing..."
    rm -rf "$NVIM_CONFIG_DIR"
fi

# Clone the Neovim configuration
git clone https://github.com/sohamw03/neovim "$NVIM_CONFIG_DIR"
echo "Neovim configuration installed."

echo "Installation complete!"

# --- Symlink Dotfiles ---
echo "Creating symlinks for dotfiles..."
cd /home/soham/
rm -f ~/.bashrc
ln -s /home/soham/dotfiles/.bashrc ~/.bashrc
rm -f ~/.gitconfig
ln -s /home/soham/dotfiles/.gitconfig ~/.gitconfig
rm -f ~/.gitignore
ln -s /home/soham/dotfiles/.gitignore ~/.gitignore
rm -f ~/.inputrc
ln -s /home/soham/dotfiles/.inputrc ~/.inputrc
rm -f ~/.profile
ln -s /home/soham/dotfiles/.profile ~/.profile
rm -f ~/.selected_editor
ln -s /home/soham/dotfiles/.selected_editor ~/.selected_editor
rm -f ~/.tmux.conf
ln -s /home/soham/dotfiles/.tmux.conf ~/.tmux.conf
rm -rf ~/.oh-my-posh-themes
ln -s /home/soham/dotfiles/.oh-my-posh-themes ~/.oh-my-posh-themes
bash $HOME/dotfiles/arch.config/link.sh
echo "Symlinks created."

mkdir /home/soham/CODE/
echo "Created /home/soham/CODE/"

# --- Switch to Zsh ---
echo "Switching shell to Zsh..."
sudo chsh -s "$(which zsh)" soham
echo "Shell changed to Zsh. Please log out and log back in for the changes to take effect."
