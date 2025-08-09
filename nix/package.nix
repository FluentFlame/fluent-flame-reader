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
  pname = "fluent-fire-reader";
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
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };
 
  npmPackFlags = [ "--ignore-scripts" ];
  npmFlags = [ "--legacy-peer-deps" ];

  nativeBuildInputs = [
    makeWrapper
    myElectron
  ];

  buildPhase = ''
    runHook preBuild

    # export ELECTRON_BUILDER_CACHE=$PWD/nix/electron_builder_cache
    npm run build
    npm exec -- electron-builder build \
      --publish=never \
      --dir \
      -c.electronDist=${myElectron.dist} \
      -c.electronVersion=${myElectron.version}

    runHook postBuild
  '';


  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/share/${pname}
    mkdir -p $out/bin
    cp -Pr --no-preserve=ownership bin/*/*/*-unpacked/{locales,resources{,.pak}} $out/share/${pname}/

    makeWrapper '${myElectron}/bin/electron' $out/bin/${pname} \
        --add-flags "$out/share/${pname}/resources/app.asar" \
        --set-default ELECTRON_FORCE_IS_PACKAGED 1
      # --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      # --set NODE_ENV production

    runHook postInstall
  '';
}
