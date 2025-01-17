{
  self,
  lib,
  ...
}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    ...
  }: let
    excludes = [
      # NOT WORKING
      # TODO: fix those
      "core"
      "ui"
      "docs"
      "assertions"

      # doesn't need to be rendered
      "_template"
    ];
  in {
    render.inputs =
      lib.flip lib.mapAttrs
      (lib.filterAttrs
        (name: module:
          ! (lib.elem name excludes))
        (self.modules.dream2nix))
      (name: module: {
        title = name;
        # module = self.modules.dream2nix.${name};
        module =
          if lib.pathExists (self.modules.dream2nix.${name} + /interface.nix)
          then (self.modules.dream2nix.${name} + /interface.nix)
          else module;
        sourcePath = self;
        attributePath = [
          "dream2nix"
          "modules"
          "dream2nix"
          (lib.strings.escapeNixIdentifier name)
        ];
        intro =
          if lib.pathExists ../dream2nix/${name}/README.md
          then lib.readFile ../dream2nix/${name}/README.md
          else "";
        baseUrl = "https://github.com/nix-community/dream2nix/blob/master";
        separateEval = true;
      });
  };
}
