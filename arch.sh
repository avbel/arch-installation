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


#encrypt_partition=/dev/mapper/archlinux

################################################################################
#### Dialog function                                                        ####
################################################################################
installer_dialog() {
    DIALOG_RESULT=$(whiptail --clear --backtitle "Arch Installer" "$@" 3>&1 1>&2 2>&3)
    DIALOG_CODE=$?
}

installer_cancel() {
if [[ $DIALOG_CODE -eq 1 ]]; then
    installer_dialog --title "Cancelled" --msgbox "\nScript was cancelled at your request." 10 60
    exit 0
fi
}

################################################################################
#### Welcome                                                                ####
################################################################################
clear
installer_dialog --title "Welcome" --msgbox "\nWelcome to Arch Linux Installer." 10 60

################################################################################
#### User account Prompts                                                   ####
################################################################################
installer_dialog --title "Root account" --msgbox "\nCreate a root account.\n" 10 60

installer_dialog --title "Root password" --passwordbox "\nEnter a strong password for the root user.\n" 10 60
root_password="$DIALOG_RESULT"
installer_cancel

installer_dialog --title "User account" --msgbox "\nCreate a user account.\n" 10 60

installer_dialog --title "username" --inputbox "\nPlease enter a username for your home account.\n" 10 60
user_name="$DIALOG_RESULT"
installer_cancel

installer_dialog --title "user password" --passwordbox "\nEnter a strong password for ${user_name}'s account.\n" 10 60
user_password="$DIALOG_RESULT"
installer_cancel

installer_dialog --title "User accounts" --msgbox "\nDone setting up accounts.\n" 10 60
################################################################################
#### Password prompts                                                       ####
################################################################################
#installer_dialog --title "Disk encryption" --passwordbox "\nEnter a strong passphrase for the disk encryption." 10 60
#encryption_passphrase="$DIALOG_RESULT"
#installer_cancel

################################################################################
#### Hostname host                                                              ####
################################################################################
installer_dialog --title "Hostname" --inputbox "\nPlease enter a hostname for this device.\n" 10 60
hostname="$DIALOG_RESULT"
installer_cancel

################################################################################
#### Processor                                                              ####
################################################################################
installer_dialog --title "Select cpu manufacturer" --menu "\nChoose an option\n" 18 100 10 "amd-ucode" "AMD Processor" "intel-ucode" "Intel Processor"		
cpu_ucode="$DIALOG_RESULT"
installer_cancel

################################################################################
#### Graphics                                                               ####
################################################################################
installer_dialog --title "Select gpu manufacturer" --menu "\nChoose an option\n" 18 100 10 "AMD" "" "Intel" "" "Nvidia" ""	
gpu_manufacturer="$DIALOG_RESULT"
installer_cancel

################################################################################
#### reset the screen                                                       ####
################################################################################
reset


################################################################################
#### Install Arch                                                           ####
################################################################################
echo "Creating filesystems and enabling swap"
mkfs.vfat ${boot_partition}
mkfs.btrfs -L root ${root_partition} -f
mkfs.btrfs -L home ${home_partition} -f
mkswap ${swap_partition}

mount ${root_partition} /mnt
mkdir /mnt/home
mount ${home_partition} /mnt/home
mkdir /mnt/boot
mount ${boot_partition} /mnt/boot


yes '' | pacstrap -i /mnt base linux linux-firmware btrfs-progs git vim $cpu_ucode lvm2  

genfstab -U /mnt >> /mnt/etc/fstab

################################################################################
#### Configure base system                                                  ####
################################################################################
kernel_version=$( ls /mnt/usr/lib/modules )

arch-chroot /mnt /bin/bash <<EOF
echo "Setting and generating locale"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo "Setting time zone"
ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime

echo "Setting hostname"
echo $hostname > /etc/hostname
sed -i '/localhost/s/$'"/ $hostname/" /etc/hosts

echo "Disabling annoying pc speaker"
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

echo "Generating initramfs"
sed -i "s/^HOOKS.*/HOOKS=\(base udev autodetect modconf block keyboard ${mkinitcpio_hooks} filesystems keyboard fsck\)/" /etc/mkinitcpio.conf
sed -i "s/^BINARIES.*/BINARIES=\(btrfs\)/" /etc/mkinitcpio.conf

mkinitcpio -g /boot/initramfs-linux.img -k $kernel_version

echo "Setting root password"
echo "root:${root_password}" | chpasswd

echo "Enable Colors, Parallel Downloads and Multilib in /etc/pacman.conf"
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i '/Color/s/^#//g' /etc/pacman.conf
sed -i '/ParallelDownloads/s/^#//g' /etc/pacman.conf


echo "Updating pacman"
pacman -Syuu
EOF

################################################################################
#### GPU Drivers                                                            ####
################################################################################
case $gpu_manufacturer in
	AMD)	
		gpu_drivers="mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon";;
	Intel)
		gpu_drivers="mesa lib32-mesa xf86-video-intel vulkan-intel";;
	Nvidia)	
		gpu_drivers="nvidia lib32-nvidia-utils";;
	*) ;;
esac

################################################################################
#### Installing basic packages                                              ####
################################################################################
arch-chroot /mnt pacman -S \
acpi \
acpi_call \
acpid \
alsa-utils \
avahi \
base-devel \
bash-completion \
bees \
bluez \
bluez-utils \
cups \
dialog \
#dnsmasq \
#dnsutils \
firewalld \
flatpak \
$gpu_drivers \
gvfs \
gvfs-smb \
#hplip \
inetutils \
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
tlp \
wpa_supplicant \
xdg-user-dirs \
xdg-utils \
wireguard-tools \
arch-chroot /mnt /bin/bash <<EOF

timedatectl set-ntp true
hwclock --systohc

systemctl enable NetworkManager 
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable firewalld
systemctl enable acpid

echo "Setting up ${user_name} account"
useradd -m ${user_name}
echo "${user_name}:${user_password}" | chpasswd
echo "${user_name} ALL=(ALL) ALL" >> /etc/sudoers.d/${user_name}
bootctl install
EOF

