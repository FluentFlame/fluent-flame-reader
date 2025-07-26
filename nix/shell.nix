{
  fluent-reader,
  mkShell,
  nodePackages,
  ...
}:

mkShell {
  packages [
    nodePackages.prettier
  ];

  inputsFrom = [
    fluent-reader
  ];
}
