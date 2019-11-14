{ stdenv, buildPackages, fetchFromGitLab, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.4.0-rc6";
  modDirVersion = version;

  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "linux-pinebook-pro";
    rev = "c32004b111aecdcd7d241409e19437a22c92766b";
    sha256 = "0r73hyqranmqcggdygi8ibmxn4vmg03ln21qs4k7gw5kx9b5zvvn";
  };

  extraConfig = ''
    CRYPTO_AEGIS128_SIMD n
  '';
} // (args.argsOverride or {}))
