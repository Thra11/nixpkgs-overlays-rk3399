self: super:
{
  mesa =
    let
      minVersion = "19.2.0";
    in
    if (self.lib.versionOlder super.mesa.version minVersion) then (super.mesa.overrideAttrs (o:
    let
      version = minVersion;
      branch  = builtins.head (self.lib.splitString "." version);
    in
    {
      inherit version;
      src =  super.fetchurl {
        urls = [
          "ftp://ftp.freedesktop.org/pub/mesa/mesa-${version}.tar.xz"
          "ftp://ftp.freedesktop.org/pub/mesa/${version}/mesa-${version}.tar.xz"
          "ftp://ftp.freedesktop.org/pub/mesa/older-versions/${branch}.x/${version}/mesa-${version}.tar.xz"
          "https://mesa.freedesktop.org/archive/mesa-${version}.tar.xz"
        ];
        sha256 = "0al5235xrsv5walyavn192mg4n4g1rykgxqg2qqn918gl2iclq5h";
      };
      postFixup = builtins.replaceStrings [
        "rm $dev/lib/pkgconfig/{gl,egl}.pc"
      ] [
        "rm $dev/lib/pkgconfig/gl.pc"
      ] o.postFixup;
    })) else super.mesa;
}
