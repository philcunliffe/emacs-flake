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
        };

        home.activation = {
          setupDoomEmacs = config.lib.dag.entryAfter ["writeBoundary"] ''
            # Copy doom-emacs to a writable location
            if [ ! -d "$HOME/.emacs.d" ]; then
              echo "Setting up Doom Emacs in writable directory..."
              $DRY_RUN_CMD cp -r "${doom-emacs}" "$HOME/.emacs.d"
              $DRY_RUN_CMD chmod -R u+w "$HOME/.emacs.d"
              $DRY_RUN_CMD chmod +x "$HOME/.emacs.d/bin/doom"
            fi
          '';
        };

      };
    };
}
