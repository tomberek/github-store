{ perlPackages }:

perlPackages.buildPerlPackage rec {
  pname = "hello-perl";
  version = "0.1";
  src = ./.;
  buildInputs = [ perlPackages.ModuleInstall ];
  postBuild = "touch $devdoc";
}
