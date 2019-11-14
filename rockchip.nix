self: super:
{
  rockchip-mpp = self.callPackage pkgs/rockchip-mpp { };
  ffmpeg_4 = (self.callPackage pkgs/ffmpeg-rockchip { Cocoa = null; }).overrideAttrs (o: {
    src = super.fetchFromGitHub {
      repo = "ffmpeg";
      owner = "rockchip-linux";
      rev = "rockchip/release/4.1";
      sha256 = "03aza9f8q0xs4nmxpag14nsl4gbl7bw00s96v0j912d8yn5sgxi6";
    };
    buildInputs = o.buildInputs ++ [ self.rockchip-mpp ];
    configureFlags = o.configureFlags ++ [ "--enable-rkmpp" ];
  });
}
