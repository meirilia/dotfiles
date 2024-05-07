# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ lib, config, pkgs, ... }:

{
  # Locales
  i18n = {
	  supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
      "id_ID.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_MEASUREMENT = "ja_JP.UTF-8";
      LC_TIME = "ja_JP.UTF-8";
      LC_PAPER = "id_ID.UTF-8";
      LC_All = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
    };
    defaultLocale = "en_US.UTF-8";
  };

  # Networking
  networking = {
	  hostName = "T480"; 
    networkmanager.enable = true;

		# Firewall
		nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPortRanges = [
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
      ];
    };
  };
  
	# Time zone
  time.timeZone = "Asia/Jakarta";

  # Bootloader settings.
  boot = {
		loader = {
	    systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

		plymouth = {
		  enable = true;
    };

		kernelParams = [ "psmouse.synaptics_intertouch=1" ];
  };
  services.fwupd.enable = true;
  
	# Enable flakes
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Hardware acceleration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver   # LIBVA_DRIVER_NAME=iHD
      intel-compute-runtime # OpenCL Driver
    ];
  };

  # Btrfs file system
  swapDevices = [ { device = "/swap/swapfile"; } ];
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  # GNOME and Xserver Settings.
  services.xserver = {
		enable = true;
    desktopManager.gnome.enable = true;

    # Remove default xserver app
		excludePackages = [ pkgs.xterm ];

		# Set to GDM + Autologin fix
		displayManager = {
		  gdm.enable = true;
		  autoLogin.enable = true;
      autoLogin.user = "archylia";
		};
  };

  # Additional autologin fix
	systemd.services = {
	  "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

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

  # Bluetooth settings
	hardware.bluetooth = {
	  powerOnBoot = false;
    settings = {
	    General = {
		    Experimental = true;
	    };
    };
  };

  # Enable autoupdate
  system.autoUpgrade.enable = true;

  # Enable OpenTabletDriver
  hardware.opentabletdriver = {
	  enable = true;
	  daemon.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
	  defaultUserShell = pkgs.fish;
	  users.archylia = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ]; 
    };
  };

  # Programs
  programs = {
	  fish.enable = true;
		xwayland.enable = true;
	  evince.enable = true;
    gnome-disks.enable = true;
		firefox = {
		  enable = true;
			nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
    };
  };

  # General Services
  services = {
	  # Throttle Fix
    throttled.enable = lib.mkDefault true;
   
    # Enable Flatpak
    flatpak.enable = true;
		
		# Printing
		printing = { 
	    enable = true; 
	    drivers = [ pkgs.epson-201401w ]; 
   	};
    
		gnome = {
		  sushi.enable = true;
      core-utilities.enable = false;
    };
	};
	
  # Remove unnecessary apps
  environment.gnome.excludePackages = [ pkgs.gnome-tour ];

  # Allow some non-free packages
	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "epson-201401w"
  ];

	# Very cool sudo feedback
  security.sudo.extraConfig = "
  Defaults pwfeedback
  ";

	# System Packages
  environment.systemPackages = with pkgs; [

    # System
		android-tools
    ffmpegthumbnailer
		firefoxpwa
		git
		htop-vim
		junction
		killall
		nh
		scrcpy
		wl-clipboard
		arrpc

    # Gnome
		blackbox-terminal
		baobab
    gnome.nautilus
		gnome.gnome-logs
    gnome.gnome-tweaks
    gnome-text-editor
		gnome-console
    resources
		gnome.nautilus-python
    gnomeExtensions.pano
    adw-gtk3

    # Printing
    system-config-printer

    # Font
    pkgs.comic-mono

  ];

  # Patches
  nixpkgs.overlays = [
	(final: prev: {
    
		# Fix Vsync issue with osu!
		xwayland = prev.xwayland.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        ./patch/xwayland-vsync.patch
      ]; 
    });

		# Mutter Dynamic Buffering Fix
    gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
      mutter = gnomePrev.mutter.overrideAttrs ( old: {
        src = pkgs.fetchgit {
          url = "https://gitlab.gnome.org/vanvugt/mutter.git";
          # GNOME 45: triple-buffering-v4-45
          rev = "0b896518b2028d9c4d6ea44806d093fd33793689";
          sha256 = "sha256-mzNy5GPlB2qkI2KEAErJQzO//uo8yO0kPQUwvGDwR4w=";
        };
      });
    });
  }) 
  ];

  # Nautilus Gstreamer Fix
  environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
    gst-plugins-good
    gst-plugins-bad
  ]);

  # Nautilus open any terminal
	services.xserver.desktopManager.gnome.extraGSettingsOverridePackages = [
      pkgs.nautilus-open-any-terminal
  ];
  environment.sessionVariables.NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
  environment.pathsToLink = [
    "/share/nautilus-python/extensions"
  ];
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "blackbox";
  };

 # Environment
  environment.variables = {
	  MOZ_USE_XINPUT2 = "1";
	  MOZ_ENABLE_WAYLAND = "1";
	  EDITOR = "nvim";
	  NIXOS_OZONE_WL = "1";
	};

  # Version which the system start first installed
  system.stateVersion = "23.11";
}
