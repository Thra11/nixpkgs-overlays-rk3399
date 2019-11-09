{ stdenv, fetchFromGitHub, fetchpatch, cmake }:

stdenv.mkDerivation rec {
  pname = "rockchip-mpp";
  version = "1.3.8";

  src = fetchFromGitHub {
    repo = "mpp";
    owner = "rockchip-linux";
#    rev = "release_20170811";
#    sha256 = "1q9kivida906mk9ps6mrcqn5sjm91jz2wp1w08m85cnh6qijiz4g";
    rev = "451ae59386bbb8093a25defdca7a95f588c28706";
    sha256 = "006kbg3wzgyrxjpxvg2nkq9wb98cnz8kjxk3ss82r8nx7cim5nk0";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];
  patches = [ ./rkmpp-0001-fix-32-bit-mmap-issue-on-64-bit-kernels.patch ];

  meta = with stdenv.lib; {
    description = "Rockchip Media Process Platform module";
    longDescription = ''
      Rockchip Media Process Platform is the video codec parser and
      Hardware Abstraction Layer library for the Rockchip platforms.
    '';
    homepage = http://opensource.rock-chips.com/wiki_Mpp;
    license = licenses.asl20;
    maintainers = with maintainers; [ Thra11 ];
    platforms = [ "aarch64-linux" ];
  };
}
