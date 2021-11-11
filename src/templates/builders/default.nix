{
  lib,
  pkgs,
  stdenv,

  # dream2nix inputs
  builders,
  externals,
  utils,
  ...
}:

{
  # Funcs

  # AttrSet -> Bool) -> AttrSet -> [x]
  getCyclicDependencies,        # name: version: -> [ {name=; version=; } ]
  getDependencies,              # name: version: -> [ {name=; version=; } ]
  getSource,                    # name: version: -> store-path
  buildPackageWithOtherBuilder, # { builder, name, version }: -> drv

  # Attributes
  subsystemAttrs,       # attrset
  mainPackageName,      # string
  mainPackageVersion,   # string

  # attrset of pname -> versions,
  # where versions is a list of version strings
  packageVersions,

  # Overrides
  # Those must be applied by the builder to each individual derivation
  # using `utils.applyOverridesToPackage`
  packageOverrides ? {},

  # Custom Options: (parametrize builder behavior)
  # These can be passed by the user via `builderArgs`.
  # All options must provide default
  standalonePackageNames ? [],
  ...
}@args:

let

  b = builtins;

  # the main package
  defaultPackage = packages."${mainPackageName}"."${mainPackageVersion}";

  # manage pakcages in attrset to prevent duplicated evaluation
  packages =
    lib.mapAttrs
      (name: versions:
        lib.genAttrs
          versions
          (version: makeOnePackage name version))
      packageVersions;

  # Generates a derivation for a specific package name + version
  makeOnePackage = name: version:
    let
      pkg =
        stdenv.mkDerivation rec {

          pname = utils.sanitizeDerivationName name;
          inherit version;

          src = getSource name version;

          buildInputs =
            map
              (dep: packages."${dep.name}"."${dep.version}")
              (getDependencies name version);
          
          # Implement build phases
          
        };
    in
      # apply packageOverrides to current derivation
      (utils.applyOverridesToPackage packageOverrides pkg name);


in
{
  inherit defaultPackage packages;
}