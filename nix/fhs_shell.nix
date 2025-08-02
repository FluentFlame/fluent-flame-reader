{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
  name = "simple-x11-env";
  targetPkgs = pkgs: (with pkgs; [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    electron
    expat
    glib
    gtk3
    libGL
    libgbm
    libxkbcommon
    libz
    nodePackages.prettier
    nodejs_24
    nspr
    nss
    pango
    udev

    appimage-run # For appimage running (not building)
  ]) ++ (with pkgs.xorg; [
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
  ]);
  multiPkgs = pkgs: (with pkgs; [
    udev
    alsa-lib
  ]);
  runScript = "bash";
}).env
