{ stdenv, buildPackages, fetchFromGitLab, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.10.0-rc5";
  modDirVersion = version;

  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "linux-pinebook-pro";
    rev = "c04087388bdb7d79d5202ffb91aa387e36901056";
    sha256 = "0igxbq8i0z6qs1kxxxs440d1n1j5p5a26lgcn7q5k82rdjqhwpw9";
  };

  extraConfig = ''
    CRYPTO_AEGIS128_SIMD n
    RTC_DRV_RK808 y
    STAGING y
    STAGING_MEDIA y
    ARCH_ROCKCHIP y
    VIDEO_DEV m
    VIDEO_V4L2 m
    MEDIA_CONTROLLER y
    MEDIA_CONTROLLER_REQUEST_API y
    VIDEO_HANTRO m
    VIDEO_HANTRO_ROCKCHIP y
  '';
} // (args.argsOverride or {}))
