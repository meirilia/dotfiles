# Neovim config

{ lib, config, pkgs, ... }:

{
 programs.neovim = {
   enable = true;
   viAlias = true;
   vimAlias = true;
	 defaultEditor = true;
   configure = {
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
		packages.myVimPackage = with pkgs.vimPlugins; {
      start = [ "coq_nvim" "nvim-scrollview" ];
    };
  };
};

}
