self: super:
{
  linux_rk3399_5_4 = self.callPackage pkgs/linux-rk3399 {
    kernelPatches =
      [ self.kernelPatches.bridge_stp_helper ];
  };
  linuxPackages_rk3399_5_4 = self.linuxPackagesFor self.linux_rk3399_5_4;
}
