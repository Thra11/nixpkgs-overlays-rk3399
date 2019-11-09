self: super:
{
  rockchip-mpp = self.callPackage pkgs/rockchip-mpp { };
  ffmpeg-rockchip = (super.ffmpeg_4.override {
    branch = "4.1";
  }).overrideAttrs (o: {
    version = "4.1.4";
    src = super.fetchFromGitHub {
      repo = "ffmpeg";
      owner = "rockchip-linux";
      rev = "rockchip/release/4.1";
      sha256 = "03aza9f8q0xs4nmxpag14nsl4gbl7bw00s96v0j912d8yn5sgxi6";
    };
    buildInputs = o.buildInputs ++ [ self.rockchip-mpp ];
    configureFlags = o.configureFlags ++ [ "--enable-rkmpp" ];
  });
  mpv = super.mpv.override {
    ffmpeg_4 = self.ffmpeg-rockchip;
  };
}
