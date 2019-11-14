{ stdenv, callPackage, fetchpatch, ...
}@args:

callPackage <nixpkgs/pkgs/development/libraries/ffmpeg/generic.nix> (args // rec {
  version = "4.1.4";
  branch = "4.1";
  sha256 = "03aza9f8q0xs4nmxpag14nsl4gbl7bw00s96v0j912d8yn5sgxi6";
})
