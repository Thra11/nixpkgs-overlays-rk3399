self: super:
{
  # Building the following 4 packages from git sources was required for panfrost support.
  # There have probably been releases since, so need to confirm what the minimum versions required are.
  libdrm = super.libdrm.overrideAttrs (o: {
    src = super.fetchgit {
      url = "https://gitlab.freedesktop.org/mesa/drm.git";
      rev = "14922551aa33e7592d2421cc89cf20a860a65310";
      sha256 = "1aly2bbmp64f9yaj5pnj1nw25vgb0rzpw1n3kif6ngxxsq1x5r19";
    };
  });
  mesa_glu = super.mesa_glu.overrideAttrs (o: {
    src = super.fetchgit {
      url = "https://gitlab.freedesktop.org/mesa/${o.pname}.git";
      rev = "dd4e18eb7557a31a3c8318d6612801329877c745";
      sha256 = "12ds0l9lasabzkqfm65ihhjc0zq9w2rgz2ijkcfr3njgpzjs367n";
    };
    nativeBuildInputs = o.nativeBuildInputs ++ [ self.autoconf self.automake self.libtool ];
    preConfigure = ''
      ./autogen.sh
    '';
  });
  mesa = super.mesa.overrideAttrs (o: {
    src = super.fetchgit {
      url = "https://gitlab.freedesktop.org/mesa/mesa.git";
      rev = "74a7e3ed3b297f441b406ff62ef9ba504ba3b06c";
      sha256 = "1lrnfgrs3qpg1awqsw15vaj70fq5z8yksfzr0cfqnvif8ia8j78m";
    };
    postFixup = builtins.replaceStrings [
      "rm $dev/lib/pkgconfig/{gl,egl}.pc"
    ] [
      "rm $dev/lib/pkgconfig/gl.pc"
    ] o.postFixup;
  });
  kmscube = super.kmscube.overrideAttrs (o: {
    src = super.fetchgit {
      url = git://anongit.freedesktop.org/mesa/kmscube;
      rev = "f632b23a528ed6b4e1fddd774db005c30ab65568";
      sha256 = "0rr58h8g1nj94ng13hdd6nn44155xg48xafyi0v843lvh09k88vh";
    };
  });
}
