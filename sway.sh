#!/bin/bash

################################################################################
#### Mirrors and Pacman.conf configuration                                  ####
################################################################################
MIRRORCOUNTRY="Germany"

sudo timedatectl set-ntp true
sudo hwclock --systohc

echo "Retrieve and filter the latest Pacman mirror list for ${MIRRORCOUNTRY}"
sudo reflector -c $MIRRORCOUNTRY -a 12 --sort rate --save /etc/pacman.d/mirrorlist

#echo "Setting up Firewall"
#sudo firewall-cmd --add-port=1025-65535/tcp --permanent
#sudo firewall-cmd --add-port=1025-65535/udp --permanent
#sudo firewall-cmd --reload

################################################################################
#### Pacman packages                                                        ####
################################################################################
echo "Enable Colors, Parallel Downloads and Multilib in /etc/pacman.conf"
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sudo sed -i '/Color/s/^#//g' /etc/pacman.conf
sudo sed -i '/ParallelDownloads/s/^#//g' /etc/pacman.conf

echo "Updating pacman"
sudo pacman -Syu

echo "Installing Sway Desktop Environment"
sudo pacman -S \
alacritty \
#blueman \
docker \
docker-compose \
libsecret \
file-roller \
firefox-developer-edition \
#gedit \
#gedit-plugins \
gnome-calculator \
gnome-keyring \
jq \
playerctl \
polkit-gnome \
qt5-wayland \
qt6-wayland \
qt5ct \
qt6ct \
smbclient \
slurp \
sway \
swayidle \
thunar \
thunar-archive-plugin \
thunar-media-tags-plugin \
thunar-volman \
#thunderbird \
tumbler \
#unrar \
imv \
wf-recorder \
wdisplays \
wget \
xorg-xwayland \
zathura \
zathura-cb \
zathura-djvu \
zathura-pdf-mupdf \
zsh \
bitwarden \
wayvnc \
mailnag  \
#nodejs \
#npm \
kdeconnect \
shotwell \
digikam \
imv \
pinta \
youtube-dl \
tig \
#neovim \
#neovim-qt \
#powerline \
diffuse \
bat \
glances 

################################################################################
#### Paru aur package manager installation                                  ####
################################################################################
echo "Installing Paru Aur package manager"
git clone https://aur.archlinux.org/paru $HOME/paru
cd ~/paru
makepkg -si ~/paru
rm -rf ~/paru

################################################################################
#### AUR Packages                                                           ####
################################################################################
echo "Installing AUR packages"
paru -S \
adobe-base-14-fonts \
arc-gtk-theme-git \
celluloid \
clipman \
#gammastep \
#gitflow-avh \
grim \
#intellij-idea-ultimate-edition \
#intellij-idea-ultimate-edition-jre \
#kanshi \
mako-git \
nerd-fonts-complete \
nnn-nerd \
otf-monaco-powerline-font-git \
otf-font-awesome \
#postman-bin \
#rambox-bin \
siji \
#spotify \
swappy \
sway-audio-idle-inhibit-git \
swaylock-effects \
tela-icon-theme \
ttf-material-design-icons-desktop-git \
visual-studio-code-bin \
waybar \
wofi \
nvm \
#wps-office \
xcursor-simp1e \
yadm-git \
zramd \
way-displays \
#slack-desktop \
ttf-ms-win11 \
google-chrome \
chromedriver \
#v4l2loopback-dkms-git \
kyocera_universal \
epson-inkjet-printer-stylus-photo-t50-series \
wlrobs \
obs-studio \
bitwarden-rofi \
insomnia-bin \
slack-wayland \
chromium-wayland-vaapi \
alvr \
peazip-qt-bin \
masterpdfeditor-free \
qeh-git \
lightzone \
mellowplayer \
kdiff3-qt \
rar \
extramaus \
qt5-styleplugins \
qt6gtk2 \
ksmbd-tools \
linux-pf \

################################################################################
#### Enabling Docker                                                        ####
################################################################################
echo "Enabling Docker"
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

################################################################################
#### Enabling Zram                                                          ####
################################################################################
sudo sed -i '/MAX_SIZE/s/^# //g' /etc/default/zramd

################################################################################
#### Gnome Theming                                                          ####
################################################################################
echo "Enabling Gnome theme and icons"
gsettings set org.gnome.desktop.interface gtk-theme 'Ark-Dark-solid'
gsettings set org.gnome.desktop.interface icon-theme 'Tela-dark'

################################################################################
#### Installing Dotfiles                                                    ####
################################################################################
echo "Installing Dotfiles"
cd ~;yadm clone https://github.com/avbel/dotfiles-1.git

################################################################################
#### Enable systemd services                                                ####
################################################################################
#sudo systemctl enable --user kanshi
sudo systemctl enable zramd

################################################################################
#### ZSH & Dotfiles Configuration                                           ####
################################################################################
echo "Installing ZSH-Snap plugin manager"
mkdir ~/.zsh-plugins
git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git $HOME/.zsh-plugins/zsh-snap

echo "Installing Docker ZSH auto completion"
mkdir -p ~/.zsh-plugins/docker-completion

curl \
	-L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/zsh/_docker-compose \
	-o ~/.zsh-plugins/docker-completion/_docker-compose

echo "Switch to and set ZSH as default"
chsh -s /usr/bin/zsh

echo "Reboot and start Sway in:"
echo -e "\e[1;32m5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
