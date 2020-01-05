self: super:
{
  ubootRockPro64 =
    if builtins.currentSystem == "aarch64-linux"
    then self.callPackage ./pkgs/u-boot { }
    else self.pkgsCross.aarch64-multiplatform.callPackage ./pkgs/u-boot { };
}
