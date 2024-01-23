# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ lib, config, pkgs, ... }:

{
  imports =
    [ 
    # Include the results of the hardware scan.
      <nixos-hardware/lenovo/thinkpad/t480>
      ./hardware-configuration.nix
    ];

  # Locales
  i18n.supportedLocales = [ 
    "en_US.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
    "id_ID.UTF-8/UTF-8"
  ];
  
  i18n.extraLocaleSettings = {
  LC_MEASUREMENT = "ja_JP.UTF-8";
  LC_TIME = "ja_JP.UTF-8";
  LC_PAPER = "id_ID.UTF-8";
  LC_All = "en_US.UTF-8";
  LANG = "en_US.UTF-8";
  }; 
  
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking.hostName = "T480"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Asia/Jakarta";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.plymouth.enable = true;

  # Hardware acceleration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver   # LIBVA_DRIVER_NAME=iHD
      intel-compute-runtime # OpenCL Driver
    ];
  };
  # Use latest kernel (by default it will use the lts kernel)
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Enable the GNOME Desktop Environment.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
   # Enable other gnome services
  programs.evince.enable = true;
  programs.gnome-disks.enable = true;
  
  # Remove unnecessary apps
  services.gnome.core-utilities.enable = false;
  environment.gnome.excludePackages = [ pkgs.gnome-tour ];
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable autoupdate
  system.autoUpgrade.enable = true;

  # Enable Flatpak
  services.flatpak.enable = true;
  
  # Enable OpenTabletDriver
  hardware.opentabletdriver.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Allow installation of proprietary apps 
  nixpkgs.config.allowUnfree = true;	
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.archylia = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [

       # Stuff
       firefox
       junction

       # Gnome
       gnome.gnome-tweaks
       gnome.gnome-system-monitor
       pkgs.gnomeExtensions.pano

     ];
   };

  # le fishe shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # System Packages
  environment.systemPackages = with pkgs; [

     # System
		 git
     htop-vim
     killall
     xwaylandvideobridge
     ffmpegthumbnailer

     # Gnome
     gnome.nautilus
     gnome-console
     gnome.gnome-logs
     gnome-text-editor
     baobab
     pkgs.adw-gtk3
     wl-clipboard
     
     # Printing
     system-config-printer
     pkgs.epson-201401w
     
     # Font
     pkgs.comic-mono
     
  ];

  # Nautilus Gstreamer fix
  environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
  gst-plugins-good
  gst-plugins-bad
  gst-plugins-ugly
  gst-libav
  ]);
  
  
  # Autologin fix 
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "archylia";
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  

  # Firewall settings
	networking.nftables.enable = true;
	networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 80 443 ];
  allowedUDPPortRanges = [
    { from = 4000; to = 4007; }
    { from = 8000; to = 8010; }
    ];
  };

  # Patches
  programs.xwayland.enable = true;
	nixpkgs.overlays = [ 
	(final: prev: {
  xwayland = prev.xwayland.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./xwayland-vsync.patch
    ]; });
  
	mutter = prev.mutter.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./mutter-dynamic-buffering.patch
    ]; });
  
  }) ];
 
 # Environment 
  environment.variables = {
	MOZ_USE_XINPUT2 = "1";
	MOZ_ENABLE_WAYLAND = "1";
	EDITOR = "nvim";
	};
	
	environment.etc = {
	"modprobe.d/psmouse.conf".text = ''
options psmouse synaptics_intertouch=1
	'';
	};

  # Swap files
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 8*1024;
  } ];
  
  # Neovim and the config
  programs.neovim.enable = true;
  programs.neovim.configure = {
    customRC = ''
  set hlsearch
  set incsearch
  set tabstop=2
  set autoindent
  set number
  set wildmode=longest,list
  syntax on
  set mouse=a
  filetype plugin on
  set ttyfast
  set spell
  set noswapfile
  '';
  };
  
  # Throttled config
  services.throttled.enable = lib.mkDefault true;
  services.throttled.extraConfig = "[GENERAL]
# Enable or disable the script execution
Enabled: True
# SYSFS path for checking if the system is running on AC power
Sysfs_Power_Path: /sys/class/power_supply/AC*/online
# Auto reload config on changes
Autoreload: True

## Settings to apply while connected to Battery power
[BATTERY]
# Update the registers every this many seconds
Update_Rate_s: 30
# Max package power for time window #1
PL1_Tdp_W: 29
# Time window #1 duration
PL1_Duration_s: 28
# Max package power for time window #2
PL2_Tdp_W: 44
# Time window #2 duration
PL2_Duration_S: 0.002
# Max allowed temperature before throttling
Trip_Temp_C: 80
# Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
cTDP: 0
# Disable BDPROCHOT (EXPERIMENTAL)
Disable_BDPROCHOT: False
## Settings to apply while connected to AC power
[AC]
# Update the registers every this many seconds
Update_Rate_s: 5
# Max package power for time window #1
PL1_Tdp_W: 44
# Time window #1 duration
PL1_Duration_s: 28
# Max package power for time window #2
PL2_Tdp_W: 44
# Time window #2 duration
PL2_Duration_S: 0.002
# Max allowed temperature before throttling
Trip_Temp_C: 90
# Set HWP energy performance hints to 'performance' on high load (EXPERIMENTAL)
# Uncomment only if you really want to use it
# HWP_Mode: False
# Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
cTDP: 0
# Disable BDPROCHOT (EXPERIMENTAL)
Disable_BDPROCHOT: False

# All voltage values are expressed in mV and *MUST* be negative (i.e. undervolt)! 
[UNDERVOLT.BATTERY]
# CPU core voltage offset (mV)
CORE: -90
# Integrated GPU voltage offset (mV)
GPU: -80
# CPU cache voltage offset (mV)
CACHE: -90
# System Agent voltage offset (mV)
UNCORE: -80
# Analog I/O voltage offset (mV)
ANALOGIO: 0

# All voltage values are expressed in mV and *MUST* be negative (i.e. undervolt)!
[UNDERVOLT.AC]
# CPU core voltage offset (mV)
CORE: -90
# Integrated GPU voltage offset (mV)
GPU: -80
# CPU cache voltage offset (mV)
CACHE: -90
# System Agent voltage offset (mV)
UNCORE: -80
# Analog I/O voltage offset (mV)
ANALOGIO: 0
";
  
  # Version which the system start first installed
  system.stateVersion = "23.11"; 
}
