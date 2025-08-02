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
  npmDepsHash = "sha256-RfofIgU7cKbv4dKSZljVD5jzrymW4gxEYuJ/qTSeK4A=";
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
    npm exec electron-builder \
      --linux \
      --x64
      # -p never \
      # -c.electronDist=${myElectron.dist} \
      # -c.electronVersion=${myElectron.version}

    runHook postBuild
  '';


  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/share
    mkdir -p $out/bin
    cp -r bin/linux/x64/linux-unpacked/resources $out/share/

    makeWrapper '${myElectron}/bin/electron' $out/bin/${pname} \
      --add-flags "$out/share/resources/app.asar"
      # --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      # --set NODE_ENV production

    runHook postInstall
  '';
}
