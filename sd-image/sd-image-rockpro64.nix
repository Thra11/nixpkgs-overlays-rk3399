# To build, use:
# nix-build <nixpkgs/nixos> -I nixos-config=./sd-image-rockpro64.nix -A config.system.build.sdImage
{ config, lib, pkgs, ... }:

let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      pkgs = pkgs.buildPackages;
    };
in
{
  imports = [
    <nixpkgs/nixos/modules/profiles/base.nix>
    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
  ];

  nixpkgs.overlays = let
    uboot = import ../uboot.nix;
    kernel = import ../kernel.nix;
    firmware = import ../firmware.nix;
    rockchip = import ../rockchip.nix;
    panfrost = import ../panfrost.nix;
  in [
    uboot
    kernel
    firmware
    rockchip
    panfrost
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel = lib.mkDefault 7;
  boot.kernelPackages = pkgs.linuxPackages_rk3399_5_4;
  boot.kernelParams = [ "console=uart8250,mmio32,0xff1a0000" "console=ttyS2,1500000n8" "video=eDP-1:1920x1080@60" ];

  hardware.firmware = [ pkgs.ap6256-firmware ];

  sdImage = {
    populateFirmwareCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        debug=on
      '';
      in ''
        dd if=${pkgs.ubootRockPro64}/idbloader.img of=$img bs=512 seek=64 oflag=direct,sync conv=notrunc
        dd if=${pkgs.ubootRockPro64}/u-boot.itb of=$img bs=512 seek=16384 oflag=direct,sync conv=notrunc
        cp ${configTxt} firmware/config.txt
      '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "panfrost" ];
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    desktopManager.plasma5.enableQt4Support = false;
    layout = "gb";
    libinput.enable = true;
  };
}
