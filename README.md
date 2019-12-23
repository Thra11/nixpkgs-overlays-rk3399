# NixOS Overlay for Pinebook Pro

This repository attempts to provide support for running NixOS on the Pinebook Pro laptop from Pine64. It is implemented as a "nixpkgs overlay", so that it's easy to update your system and switch between different channels without losing your Pinebook Pro-specific tweaks.

The repository also contains an sd-image definition. This is not strictly part of the overlay, but it can be used to build a bootable SD card image including the changes from the overlay.

The overlay includes:
* Linux kernel 5.4.0 + changes by @tsys of manjaro
* ~Mainline u-boot, courtesy of @samueldr
* Mesa 19.2.0 *if* the version in nixpkgs is too old

## Using the overlay

Following [these](https://nixos.wiki/wiki/Overlays) instructions, clone the repository somewhere (such as `/etc/nixos/overlays`) and apply the overlay in `/etc/nixos/configuration.nix`. For example:
```
  nixPath = [
    # You can add nixpkgs-overlays to the nix path allows users to use the overlay
    "nixpkgs-overlays=/etc/nixos/overlays"
  ];

  # Import the overlays which you wish to use
  nixpkgs.overlays = let
    kernel = import ./overlays/kernel.nix;
    firmware = import ./overlays/firmware.nix;
    panfrost = import ./overlays/panfrost.nix;
  in [
    kernel
    firmware
    panfrost
  ];

  # Use the kernel from the overlay instead of kernels in nixpkgs which do not yet support all pinebook pro features
  boot.kernelPackages = pkgs.linuxPackages_rk3399_5_4;

  # Include additional firmware packages to support the wifi module
  hardware.firmware = [ pkgs.ap6256-firmware ];

```

## Building a Bootable SD Image

Requirements
* A linux machine with Nix installed (doesn't have to be NixOS Linux), capable of compiling or cross-compiling for aarch64.

To build the image, run the following command. Note that this will use whatever channel or path is configured as `<nixpkgs>` on the build host, with the overlay applied.
```
nix-build <nixpkgs/nixos> -I nixos-config=./sd-image-rockpro64.nix -A config.system.build.sdImage
```
This will produce a symlink called `result` in the working directory, pointing to a path in the nix store containing an SD image. Depending which branch/version of nixpkgs you used, it may or may not be compressed (more recent nixpkgs use bzip2 to compress the finished image).

## Updating the keyboard/trackpad firmware

The procedure is exactly as described in the original instructions. However, instead of running
```
sudo apt-get install build-essential libusb-1.0-0-dev xxd
```
to get the required dependencies, we need the equivalent nix packages. Clone the repository:
```
git clone https://github.com/ayufan-rock64/pinebook-pro-keyboard-updater
```
Inside the repository, create a file called `shell.nix`, with the following contents:
```
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  baseInputs = [ pkgs.gnumake pkgs.xxd ];
  buildInputs = [ pkgs.libusb ];
}
```
Now, running `nix-shell` inside the directory will drop you into a shell containing the build tools and dependencies required. You can then proceed to run `make` and continue with the original instructions.
