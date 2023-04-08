#!/bin/sh

echo "Make sure you have connected to the internet first!"
echo "NOTE! this only work if you have UEFI and your UEFI aint shit"
timedatectl

setup() {
	# To Partition Disk
	echo "Which disk do you want to be partitioned (/dev/...)?"
	read DISK
	echo "BE SURE TO DOUBLE CHECK!"
	read -n 1 -r -s -p $'Press enter to continue...\n'
	cfdisk $DISK

	# Choose EFI partition and Root Partition
	echo "Insert your EFI partition (/dev/...)"
	read EFI

	echo "Insert your root partition (/dev/..."
	read ROOT

	echo "What file system do you want to have (ext4 or btrfs)?"
	read FS

	mkfs.fat -F -32 $EFI
	mkfs.$FS $ROOT

	echo "Mounting..."
	mount $ROOT /mnt
	mount $EFI /mnt/boot
}

chroot() {
	# Install base system
	echo "What processor do you have (amd or intel)? (type with lowercase)"
	read CPU
	
	echo "Installing base system"
	pacstrap -K /mnt base linux linux-firmware vim $CPU-ucode networkmanager efibootmgr
	genfstab -U /mnt >> /mnt/etc/fstab

	echo "Chrooting..."
	arch-chroot /mnt

	# Timezone
	echo "What's your timezone (Format = Region//City, e.g. Asia/Jakarta)?"
	read TIMEZONE
	ln -sf /usr/share/zoneinfo/$TIMEZONE

	# Locale
	echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
	echo "LANG=en_US.UTF-8" > /etc/locale.conf

	# Network
	echo "Insert your hostname so people can know you"
	read HOSTNAME
	echo "$HOSTNAME" >> /etc/hostname

	# Recreate Initramfs
	echo "Creating initramfs..."
	mkinitcpio -P

	# Root Password
	echo "Create a super secure password for root :3"
	passwd
	
	# EFISTUB
	echo "Installing EFISTUB Bootloader"
	
	echo "What cool name do you want to display on your bootloader (no space or some reason it will fuck up)?"
	read LABEL

	echo "Insert your block device identifier (run BLKID first to know, yes i know but how do you automate this help)"
	read UUID

	echo "Any rootflags do you want to add?"
	read ROOTFLAGS

	INITRD="initrd=$CPU-ucode.img initrd=initramfs-linux.img"

	echo "Actually Installing it"
	efibootmgr --create --disk $ROOT --part 1 --label "$LABEL" --loader vmlinuz-linux --unicode 'root=$UUID $ROOTFLAGS $INITRD'

	echo "ok that's it, you can reboot (hopefully) safely now\n if it doesnt, chroot and RTFM lol"
	read -n 1 -r -s -p $'Press enter to end it all...\n'
}

