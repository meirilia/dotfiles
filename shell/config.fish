if status is-interactive

# Export
set -x PATH $PATH:~/.spoof-dpi/bin
set -x SUDO_PROMPT "$(tput setaf 1 bold)Input your password please :3 $(tput sgr0)$(tput setaf 2 bold)-->$(tput sgr0) "
set -x MANPAGER "nvim +Man!"

# Colors
set red "\033[0;31m"
set Bred "\033[1;31m"
set blue "\033[0;34m"
set cyan "\033[0;36m"
set purple "\033[0;35m"
set green "\033[0;32m" 
set nc "\033[0m"
set yellow "\033[0;33m"


# Flatpak
alias flatin="flatpak install --user"
alias flatup="flatpak update"
alias flatrem="flatpak remove"
alias flatrun="flatpak run"

# Other
alias applist="echo -e ':: $yellow NixOS packages $nc'; nix-store -q --references /var/run/current-system/sw | cut -d'-' -f2- | pr -4 -t -W 150 -s' | '; echo -e '\n \n:: $yellow Flatpak Packages $nc' && flatpak list --columns=name --columns=application --app"

# Nice things
alias nixconf="sudo nvim /etc/nixos/configuration.nix"
alias nixbuild="nh os switch /etc/nixos/"
alias nixclean="nh clean all -k 3"
alias flakeconf="sudo nvim /etc/nixos/flake.nix"
alias fishconf="nvim .config/fish/config.fish"

end

