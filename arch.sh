#!/bin/bash

################################################################################
#### Disk variables (todo menu prompt to select a specific disk             ####
################################################################################
install_disk=/dev/sda
boot_partition=/dev/sda1
swap_partition=/dev/sda2
root_partition=/dev/sda3
home_partition=/dev/sda4
#install_disk=/dev/nvme0n1
#boot_partition=/dev/nvme0n1p1
#swap_partition=/dev/nvme0n1p2
#root_partition=/dev/nvme0n1p3
#home_partition=/dev/nvme0n1p4
user_name=andrey

MIRRORCOUNTRY="Germany"


kernel_version=$( ls /mnt/usr/lib/modules )

echo "Disabling annoying pc speaker"
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

echo "Generating initramfs"
sed -i "s/^BINARIES.*/BINARIES=\(btrfs\)/" /etc/mkinitcpio.conf
mkinitcpio -g /boot/initramfs-linux.img -k $kernel_version


echo "Enable Colors, Parallel Downloads and Multilib in /etc/pacman.conf"
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i '/Color/s/^#//g' /etc/pacman.conf
sed -i '/ParallelDownloads/s/^#//g' /etc/pacman.conf

echo "Retrieve and filter the latest Pacman mirror list for ${MIRRORCOUNTRY}"
sudo reflector -c $MIRRORCOUNTRY -a 12 --sort rate --save /etc/pacman.d/mirrorlist

echo "Updating pacman"
pacman -Syuu

################################################################################
#### Installing basic packages                                              ####
################################################################################
pacman -S \
acpi \
acpi_call \
acpid \
alsa-utils \
avahi \
vim \
git \
#base-devel \
bash-completion \
bees \
cups \
dialog \
#dnsmasq \
#dnsutils \
firewalld \
flatpak \
mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon \
gvfs \
gvfs-smb \
#hplip \
ipset \
iptables-nft \
#linux-headers \
nss-mdns \
#ntfs-3g \
openssh \
pipewire \
pipewire-alsa \
pipewire-jack \
pipewire-pulse \
reflector \
rsync \
rclone \
restic \
smbclient \
sof-firmware \
terminus-font \
xdg-user-dirs \
xdg-utils 

################################################################################
#### Paru aur package manager installation                                  ####
################################################################################
echo "Installing Paru Aur package manager"
git clone https://aur.archlinux.org/paru /tmp/paru
cd /tmp/paru
makepkg -si /tmp/paru
rm -rf /tmp/paru

echo "Enabling services"
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable firewalld
systemctl enable acpid

echo "Setting up ${user_name} account"
echo "${user_name} ALL=(ALL) ALL" >> /etc/sudoers.d/${user_name}

