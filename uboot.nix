self: super:
{
  ubootRockPro64 = super.ubootRockPro64.overrideAttrs (o: {
    extraPatches = o.extraPatches ++ [
      ./patches/0001-Offset-ramdisk-to-accomodate-larger-kernel.patch
    ];
  });
}
