{
  buildNpmPackage,
  electron,
  fetchFromGitHub,
  makeWrapper,
  ...
}:
let
  myElectron = electron;

in

buildNpmPackage rec {
  pname = "fluent-reader";
  version = "1.1.4";
  src = ../.;
  npmDepsHash = "sha256-cOtGJtex6dZUFqpKrukCs4A0A1UV4eZGMSDKyXEDvAE=";
  makeCacheWritable = true;
  # src = fetchFromGitHub {
  #   owner = "yang991178";
  #   repo = "fluent-reader";
  #   rev = "v${version}";
  #   hash = "sha256-/VBXm6KiwJC/JTKp8m/dkmGmPZ2x2fHYiX9ylw8eDvY=";
  # };

  # npmDepsHash = "sha256-okonmZMhsftTtmg4vAK1n48IiG+cUG9AM5GI6wF0SnM=";
  
  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };
 
  npmPackFlags = [ "--ignore-scripts" ];
  npmFlags = [ "--legacy-peer-deps" ];

  nativeBuildInputs = [
    makeWrapper
    myElectron
  ];

  buildPhase = ''
    runHook preBuild

    npm run build
    npm exec electron-builder -- \
      --dir \
      -c.electronDist=${myElectron.dist} \
      -c.electronVersion=${myElectron.version}

    runHook postBuild
  '';


  installPhase = ''
    runHook preInstall

    makeWrapper '${myElectron}/bin/electron' "$out/dist/electron.js" \
      # --add-flags "$out/share/appium-inspector/resources/app.asar" \
      # --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      # --set NODE_ENV production

    runHook postInstall
  '';
}
