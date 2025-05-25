{
  description = "Doom Emacs configuration as a Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    doom-emacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, doom-emacs }:
    {
      homeManagerModules.default = { config, pkgs, ... }: {
        programs.emacs = {
          enable = true;
          package = pkgs.emacs30;
        };

        home.packages = with pkgs; [
          # Required for Doom Emacs
          git
          ripgrep
          fd
        ];

        home.file = {
          ".doom.d/config.el".source = "${self}/config.el";
          ".doom.d/init.el".source = "${self}/init.el";
          ".doom.d/packages.el".source = "${self}/packages.el";
          ".emacs.d".source = doom-emacs;
        };

      };
    };
}
