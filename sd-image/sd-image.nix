# This module creates a bootable SD card image containing the given NixOS
# configuration. The generated image is MBR partitioned, with an ext4 root
# partition. The generated image is sized to fit its contents, and a boot script
# automatically resizes the root partition to fit the device on the first boot.
#
# The derivation for the SD image will be placed in
# config.system.build.sdImage

{ config, lib, pkgs, ... }:

with lib;

let
  rootfsImage = pkgs.callPackage <nixpkgs/nixos/lib/make-ext4-fs.nix> ({
    inherit (config.sdImage) storePaths;
    populateImageCommands = config.sdImage.populateRootCommands;
    volumeLabel = "NIXOS_SD";
  } // optionalAttrs (config.sdImage.rootPartitionUUID != null) {
    uuid = config.sdImage.rootPartitionUUID;
  });
in
{
  options.sdImage = {
    imageName = mkOption {
      default = "${config.sdImage.imageBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.img";
      description = ''
        Name of the generated image file.
      '';
    };

    imageBaseName = mkOption {
      default = "nixos-sd-image";
      description = ''
        Prefix of the name of the generated image file.
      '';
    };

    storePaths = mkOption {
      type = with types; listOf package;
      example = literalExample "[ pkgs.stdenv ]";
      description = ''
        Derivations to be included in the Nix store in the generated SD image.
      '';
    };

    rootPartitionUUID = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
      description = ''
        UUID for the main NixOS partition on the SD card.
      '';
    };

    populateFirmwareCommands = mkOption {
      example = literalExample "'' cp \${pkgs.myBootLoader}/u-boot.bin firmware/ ''";
      description = ''
        Shell commands to populate the ./firmware directory.
        All files in that directory are copied to the
        /boot/firmware partition on the SD image.
      '';
    };

    populateRootCommands = mkOption {
      example = literalExample "''\${extlinux-conf-builder} -t 3 -c \${config.system.build.toplevel} -d ./files/boot''";
      description = ''
        Shell commands to populate the ./files directory.
        All files in that directory are copied to the
        root (/) partition on the SD image. Use this to
        populate the ./files/boot (/boot) directory.
      '';
    };

    populateUBootCommands = mkOption {
      example = literalExample "''dd if=${pkgs.ubootRockPro64}/u-boot.itb of=$img bs=512 seek=16384 oflag=direct,sync conv=notrunc''";
      description = ''
        Shell commands to write u-boot to the appropriate offset.
      '';
    };

    compressImage = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether the SD image should be compressed using
        <command>bzip2</command>.
      '';
    };

  };

  config = {
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
    };

    sdImage.storePaths = [ config.system.build.toplevel ];

    system.build.sdImage = pkgs.callPackage ({ stdenv, dosfstools, e2fsprogs, mtools, libfaketime, utillinux, bzip2 }: stdenv.mkDerivation {
      name = config.sdImage.imageName;

      nativeBuildInputs = [ dosfstools e2fsprogs mtools libfaketime utillinux bzip2 ];

      inherit (config.sdImage) compressImage;

      buildCommand = ''
        mkdir -p $out/nix-support $out/sd-image
        export img=$out/sd-image/${config.sdImage.imageName}

        echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
        if test -n "$compressImage"; then
          echo "file sd-image $img.bz2" >> $out/nix-support/hydra-build-products
        else
          echo "file sd-image $img" >> $out/nix-support/hydra-build-products
        fi

        # Gap in front of the first partition, in MiB
        gap=8

        # Create the image file sized to fit /boot/firmware and /, plus slack for the gap.
        rootSizeBlocks=$(du -B 512 --apparent-size ${rootfsImage} | awk '{ print $1 }')
        imageSize=$((rootSizeBlocks * 512 + gap * 1024 * 1024))
        truncate -s $imageSize $img

        # type=b is 'W95 FAT32', type=83 is 'Linux'.
        # The "bootable" partition is where u-boot will look file for the bootloader
        # information (dtbs, extlinux.conf file).
        sfdisk $img <<EOF
            start=''${gap}M, type=83, bootable
        EOF

        # Copy the rootfs into the SD image
        eval $(partx $img -o START,SECTORS --nr 1 --pairs)
        dd conv=notrunc if=${rootfsImage} of=$img seek=$START count=$SECTORS

        # Write u-boot files
        ${config.sdImage.populateUBootCommands}

        if test -n "$compressImage"; then
            bzip2 $img
        fi
      '';
    }) {};

    boot.postBootCommands = ''
      # On the first boot do some maintenance tasks
      if [ -f /nix-path-registration ]; then
        set -euo pipefail
        set -x
        # Figure out device names for the boot device and root filesystem.
        rootPart=$(${pkgs.utillinux}/bin/findmnt -n -o SOURCE /)
        bootDevice=$(lsblk -npo PKNAME $rootPart)

        # Resize the root partition and the filesystem to fit the disk
        echo ",+," | sfdisk -N2 --no-reread $bootDevice
        ${pkgs.parted}/bin/partprobe
        ${pkgs.e2fsprogs}/bin/resize2fs $rootPart

        # Register the contents of the initial Nix store
        ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration

        # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
        touch /etc/NIXOS
        ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

        # Prevents this from running on later boots.
        rm -f /nix-path-registration
      fi
    '';
  };
}
