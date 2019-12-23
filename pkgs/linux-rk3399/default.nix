{ stdenv, buildPackages, fetchFromGitLab, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.4.0";
  modDirVersion = version;

  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "linux-pinebook-pro";
    rev = "9fdcc6656ef791322cb695c4f6ad8c26d5dcbd99";
    sha256 = "0gxbdh2yh6i4v4sjvn0x57ds3zh582392ma3ng96dk07i08jaxha";
  };

  extraConfig = ''
    CRYPTO_AEGIS128_SIMD n
    RTC_DRV_RK808 y
    VIDEO_HANTRO m
    VIDEO_HANTRO_ROCKCHIP y
  '';
} // (args.argsOverride or {}))
