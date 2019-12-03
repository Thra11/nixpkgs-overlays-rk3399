{ stdenv, buildPackages, fetchFromGitLab, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.4.0";
  modDirVersion = version;

  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "linux-pinebook-pro";
    rev = "086dae8ef292a018ae1f2ef043897593f5446174";
    sha256 = "0nhzbsqzjgbb10rpnhrh11a1lahj3qga257v2g9wj7mw2mdrs8yl";
  };

  extraConfig = ''
    CRYPTO_AEGIS128_SIMD n
  '';
} // (args.argsOverride or {}))
