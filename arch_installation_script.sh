#!/bin/sh

RED='\033[0;31m'
BLUE='\033[0;36m'
ORANGE='\033[0;33m'
NC='\033[0m'

echo -e "${RED} Make sure you have connected to the internet first! ${NC}"
echo -e "${ORANGE} NOTE! this only work if you have UEFI and your UEFI aint shit ${NC}"
timedatectl
read -p "Proceed? Yes(y) / No(n) : " choice

case $choice in
	y ) echo "";;
	n ) echo -e "${RED} Terminated by user! ${NC}";
	    exit;;
	* ) echo -e "${RED} Invalid response, responding with termination! ${NC}";
	    exit 1;;
esac

# To Partition Disk
echo -e "${ORANGE} Which disk do you want to be partitioned? (/dev/sdX or /dev/nvme0nX) \n ${NC}"
lsblk --fs
printf "\n${BLUE} Enter : ${NC}"
read DISK
echo -e "${RED} BE SURE TO DOUBLE CHECK! ${NC}"
read -n 1 -r -s -p $'Press enter to continue...\n'
cfdisk $DISK

# Choose EFI partition and Root Partition
lsblk
printf "${BLUE} Insert your EFI partition : ${NC}"
read EFI

printf "${BLUE} Insert your root partition : ${NC}"
read ROOT

printf "${BLUE} What file system do you want to have (ext4/btrfs)? ${NC}"
read FS

mkfs.fat -F 32 $EFI
mkfs.$FS $ROOT

echo -e "${ORANGE} Mounting... ${NC}"
mount $ROOT /mnt
mount $EFI --mkdir /mnt/boot

# Install base system
printf "${BLUE} What processor do you have (amd/intel)? ${NC}"
read CPU
	
echo -e "${ORANGE} Installing base system.${NC}"
pacstrap -K /mnt base linux linux-firmware neovim $CPU-ucode networkmanager
genfstab -U /mnt >> /mnt/etc/fstab

# Timezone
printf "${BLUE} What's your timezone (Format = Region/City, e.g. Asia/Jakarta)? ${NC}"
read TIMEZONE
ln -sf /mnt/usr/share/zoneinfo/$TIMEZONE

# Locale
echo -e "en_US.UTF-8 UTF-8" > /mnt/etc/locale.gen
echo -e "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

# Network
printf "${BLUE} Insert your hostname so people can know you : ${NC}"
read HOSTNAME
echo -e "$HOSTNAME" >> /mnt/etc/hostname

# Recreate Initramfs
echo -e "${ORANGE} Creating initramfs...${NC}"
mkinitcpio --config /mnt/etc/mkinitcpio.conf --generate /mnt/boot/initramfs-linux.img

# Systemd-boot
echo -e "${ORANGE} Installing systemd-boot...${NC}"
lsblk --fs
printf "${BLUE} Insert your root UUID : ${NC}"
read UUID
bootctl --esp-path=/mnt/boot/ --boot-path=/mnt/boot install
cat > /mnt/boot/loader/loader.conf <<- EOM
default  arch.conf
timeout  4
console-mode max
editor   no
EOM
cat > /mnt/boot/loader/entries/arch.conf <<- EOM
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=UUID=${UUID} rw
EOM

# The End
echo -e "${BLUE} Ok that's it! All you need to do now is to create a password for root user \n
Just type :${NC} passwd \n
${ORANGE} Chrooting... {$NC}"
arch-chroot /mnt
	
