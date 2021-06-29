self: super:
{
  rockchip-remove-capacity-dmips = {
    name = "rockchip-remove-capacity-dmips";
    patch = ./pkgs/linux-rk3399/0001-arm64-dts-rockchip-remove-capacity-dmips-rk3399.patch;
  };
  linux_rk3399 = self.callPackage pkgs/linux-rk3399 {
    kernelPatches = [
      self.kernelPatches.bridge_stp_helper
      self.rockchip-remove-capacity-dmips
    ];
  };
  linuxPackages_rk3399 = self.linuxPackagesFor self.linux_rk3399;
}
