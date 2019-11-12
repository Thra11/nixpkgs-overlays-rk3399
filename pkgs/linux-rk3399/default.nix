{ stdenv, buildPackages, fetchFromGitLab, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.4.0-rc6";
  modDirVersion = version;

  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "linux-pinebook-pro";
    rev = "e869c8685c0564d081f349bf2359c0d5d47e697e";
    sha256 = "1qaxrsdh7avmd94jkf6wypyw11cf96d4dsjasnv70izgzdif33hl";
  };

  extraConfig = ''
    CRYPTO_AEGIS128_SIMD n
  '';
} // (args.argsOverride or {}))
