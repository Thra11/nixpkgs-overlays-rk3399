{ stdenv, fetchgit, lib }:

stdenv.mkDerivation rec {
  pname = "ap6256-firmware";
  version = "2019-11";

  dontUnpack = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/lib/firmware
    install -Dm644 "${./BCM4345C5.hcd}" "$out/lib/firmware/BCM4345C5.hcd"
    install -Dm644 "${./BCM4345C5.hcd}" "$out/lib/firmware/brcm/BCM4345C5.hcd"
    install -Dm644 "${./BCM4345C5.hcd}" "$out/lib/firmware/brcm/BCM.hcd"
    install -Dm644 "${./nvram_ap6256.txt}" "$out/lib/firmware/nvram_ap6256.txt"
    install -Dm644 "${./fw_bcm43456c5_ag.bin}" "$out/lib/firmware/brcm/brcmfmac43456-sdio.bin"
    install -Dm644 "${./nvram_ap6256.txt}" "$out/lib/firmware/brcm/brcmfmac43456-sdio.radxa,rockpi4.txt"
    install -Dm644 "${./nvram_ap6256.txt}" "$out/lib/firmware/brcm/brcmfmac43456-sdio.pine64,pinebook-pro.txt"
    install -Dm644 "${./brcmfmac43456-sdio.clm_blob}" "$out/lib/firmware/brcm/brcmfmac43456-sdio.clm_blob"
  '';
  meta = with lib; {
    description = "Firmware files for the ap6256 wifi/bt module";
    homepage = "https://github.com/radxa/rk-rootfs-build";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    maintainers = with maintainers; [ Thra11 ];
    priority = 6; # give precedence to kernel firmware
  };
}
