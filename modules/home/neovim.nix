{ inputs, pkgs, ... }:
let
  nvim = inputs.nix-wrapper-modules.lib.evalPackage [
    {
      inherit pkgs;
      _module.args.inputs = inputs;
    }
    ./neovim-wrapper.nix
  ];
in
{
  # The wrapper owns the executable, plugin/runtime closure, and immutable Lua
  # sources. `~/.config/nvim` is linked as a convenient read-only source view;
  # generated state still goes to Neovim's normal XDG locations.
  home.packages = [
    nvim
    pkgs.bubblewrap
  ];

  xdg.configFile."nvim".source = ../../config/nvim;
}
