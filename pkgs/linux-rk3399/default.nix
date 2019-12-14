{ stdenv, buildPackages, fetchFromGitLab, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.4.0";
  modDirVersion = version;

  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "linux-pinebook-pro";
    rev = "f889ca0e5126672b639b90319ee2a27f272dcd60";
    sha256 = "0af1pl0731bk273qdg1x29qkfqqxifvnsb7hnm59fiik1x0ihfj5";
  };

  extraConfig = ''
    CRYPTO_AEGIS128_SIMD n
  '';
} // (args.argsOverride or {}))
