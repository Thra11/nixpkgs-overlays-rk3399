{ stdenv, buildPackages, fetchFromGitLab, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.4.0-rc6";
  modDirVersion = version;

  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "linux-pinebook-pro";
    rev = "64169f45b2ec28108917e67dc29a2d341d82acdb";
    sha256 = "1nhk17bn5dmcpknvhmkzlmlc26kx4mg7y3fad6ggqkxj3vbyj9hl";
  };

  extraConfig = ''
    CRYPTO_AEGIS128_SIMD n
  '';
} // (args.argsOverride or {}))
