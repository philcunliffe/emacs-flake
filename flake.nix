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

        home.activation = {
          doomSync = config.lib.dag.entryAfter ["writeBoundary"] ''
            if [ ! -f "$HOME/.emacs.d/bin/doom" ]; then
              echo "Doom Emacs not found, skipping sync"
              exit 0
            fi
            
            export PATH="${config.programs.emacs.package}/bin:$PATH"
            $DRY_RUN_CMD $HOME/.emacs.d/bin/doom install --force
            $DRY_RUN_CMD $HOME/.emacs.d/bin/doom sync
          '';
        };
      };
    };
}
