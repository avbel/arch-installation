# Arch linux - Installation script
This is my personal repo to install Arch Linux. I am not an expert so don't blindy install and think you get an out-of-the-box vanilla Arch experience. 

My installation consists out of packages I have a personal preference for. Use it as a demo or check out the source as an inspiration but it is probably not suitable as a daily operating system if you have no experience using and maintaining an Arch distro. In addition, my personal Dotfiles are also installed.
 
My `arch.sh` installation script assumes you are installing Arch on a nvme ssd (***nvme0n1***). Find your own designated installation device by first looking it up via `lsblk`. The disk path is still hardcoded in my `arch.sh` script. So change that if your path differs.

## Create and boot the Arch installer
1. Grab the latest Arch iso from [https://archlinux.org/](https://archlinux.org).
2. Write the image to a USB device: `sudo dd bs=4M if=arch.iso of=/dev/sdx conv=fdatasync status=progress`
3. Boot the Arch usb installer.

## Basic Arch installation
1. I'm assuming you have an active internet connection if not: [Arch Wiki - Connect to the Internet](https://wiki.archlinux.org/title/installation_guide#Connect_to_the_internet)
2. `curl https://raw.githubusercontent.com/avbel/arch-installation/main/arch.sh -o arch.sh`
3. `chmod +x arch.sh; ./arch.sh`
4. Follow the installation and after it's done it will automatically reboot to
   your Arch installation.

## Sway installation
2. `curl https://raw.githubusercontent.com/avbel/arch-installation/main/sway.sh -o sway.sh`
3. `chmod +x sway.sh; ./sway.sh` _The AUR `nerds-fonts-complete` package is > 1GB and takes a long time to
install so just wait._ 
4. Follow the installation and after it's done it will automatically reboot to
   the Sway window manager.

## Optional ZRAM
1. Install Zramd aur package: `paru -S zramd`
2. Edit the config file at: `/etc/default/zramd`
3. Enable using: `sudo systemctl enable --now zramd.service`

## Timeshift settings
1. Select “BTRFS” as the “Snapshot Type”; continue with “Next”
2. Choose your BTRFS system partition as “Snapshot Location”; continue with “Next”
3. “Select Snapshot Levels” (type and number of snapshots that will be automatically created and managed/deleted by Timeshift), recommendations:
    - Keep “Daily” at 5
    - Activate “Boot”, but change to 3
    - Activate “Stop cron emails for scheduled tasks”
    - Continue with “Next”
    - I also include @home subvolume (which is not selected by default). Note that when you restore a snapshot Timeshift will ask you again whether or not to include @home in the restore process.
    - Click “Finish”
4. “Create” your first snapshot manually and exit Timeshift.
