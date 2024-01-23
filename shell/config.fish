if status is-interactive

# Export
set -x PATH $PATH:~/.spoof-dpi/bin

# Colors
set red "\033[0;31m"
set Bred "\033[1;31m"
set blue "\033[0;34m"
set cyan "\033[0;36m"
set purple "\033[0;35m"
set green "\033[0;32m" 
set nc "\033[0m"
set yellow "\033[0;33m"

# Variables for efibootmgr
set disk "/dev/nvme0n1p1" # UEFI boot partition (the one with fat32/16)
set label "archlinux-clear" # the name (idk what the exact name is) from UEFI bootloader
set kernel "vmlinuz-linux-clear" # kernel to boot from
set rootdisk "PARTUUID=84a70460-722d-fe43-87dc-3b066d35b74b" # root partition
set rootflags "nowatchdog fastboot vt.global_cursor_default=0 rd.udev.log_priority=3 rootflags=subvol=@ splash lsm=landlock,yama,integrity,apparmor,bpf" # self-explanotary
set initrd "initrd=intel-ucode.img initrd=initramfs-linux-clear.img" # initramfs and processor ucode stuff
set linux_clear_defaults "console=tty0 console=ttyS0,115200n8 cryptomgr.notests initcall_debug intel_iommu=igfx_off kvm-intel.nested=1 no_timer_check noreplace-smp page_alloc.shuffle=1 rcupdate.rcu_expedited=1 rootfstype=btrfs tsc=reliable rw"

# Variables for kernel compilation
set option "_localmodcfg=y _subarch=27"

# -- Aliases
# System 
alias sysup="echo -e '\n $yellow Running as superuser $nc' && sudo -v\

echo -e '\n$nc :: $cyan Updating Archlinux... $nc';

if sudo pacman -Syu 
  echo -e '$green Update Successfull! $nc \n' 
else if echo -e '\n『 $Bred Not using Arch $nc | $yellow Trying NixOS $nc 』\n' 
  echo -e '$nc :: $cyan Updating NixOS... $nc'
  sudo nixos-rebuild switch 
	echo -e '\n $green Update Successfull! $nc \n' 
else 
  echo '\n『 $red Not using NixOS, what da hell do u use?$nc 』' 
end;

echo -e '$nc :: $cyan Updating Flatpak... $nc'; flatpak update; echo -e '\n $green Update Successfull! \n'"

# Pacman
alias pacin="sudo pacman -S"
alias pacrem="sudo pacman -Rnsc"
alias pacsrc="sudo pacman -Fy"
alias pacun="sudo pacman -U"
alias rmlock="sudo rm /var/lib/pacman/db.lock"
alias syscln="pacman -Qtdq | sudo pacman -Rns -"

# Flatpak
alias flatin="flatpak install --user"
alias flatup="flatpak update"
alias flatrem="flatpak remove"

# Other
alias applist="echo -e '\n :: $yellow Arch Packages $nc \n'; pacman -Qet | pr -4 -t -w 150 -s' | '; echo -e '\n :: $yellow Nixpkgs packages $nc'; cat /etc/current-system-packages | pr -4 -t -W 150 -s' | '; echo -e '\n \n:: $yellow Flatpak Packages $nc' && flatpak list --columns=name --columns=application --app"

alias bootup="sudo efibootmgr --create --disk $disk --part 1 --label "$label" --loader $kernel --unicode 'root=$rootdisk $linux_clear_defaults $rootflags $initrd'"
alias bootlist="efibootmgr -u"

# QoL
alias vim="nvim"
alias vimenv="sudo -e /etc/environment"
alias vimpac="sudo -e /etc/pacman.conf"
alias vimtemp="sudo -e /etc/throttled.conf"
alias nixconf="sudo -e /etc/nixos/configuration.nix"
alias nixbuild="sudo nixos-rebuild switch"

alias startde="XDG_SESSION_TYPE=wayland dbus-run-session gnome-session"
alias delcache="sync; echo 1 > /proc/sys/vm/drop_caches"
alias makekernel="cd /home/archylia/Downloads/git_repos/linux-clear/; git pull; env $option makepkg -sfcCr"

    # Commands to run in interactive sessions can go here
end
